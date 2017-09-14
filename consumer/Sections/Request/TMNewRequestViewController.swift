//  TMNewRequestViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/11/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import Contacts
import CoreStore
import SwiftyJSON
import PromiseKit
import SVProgressHUD
import IQKeyboardManagerSwift
import JDStatusBarNotification
    
import EZSwiftExtensions

protocol TMNewRequestViewControllerCoordinatorDelegate {
    
    /// Tells coordinator that the back button was tapped.
    func onBackButton(_ viewController: TMNewRequestViewController)
}
 
class TMNewRequestViewController: UIViewController, TMNavigationThemeProtocol {

    /// New request cells
    enum TMNewRequestViewControllerCells: Int {
        
        case contact = 0
        case location
        case occasion
        case price
        case interests
        case style
        case details
        case button
        
        static let allData: [TMNewRequestViewControllerCells] = [.contact, .location, .occasion, .price, .style, .interests, .details, .button]
    }
    
    /// Coordinator delegate
    var coordinatorDelegate: TMNewRequestViewControllerCoordinatorDelegate?
    
    /// Collection view setup
    lazy var collectionView: UICollectionView = {
       
        // Collection layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        // Collection view init
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.TMGrayBackgroundColor
        
        /// Cells setup
        // Contacts selection cell
        // '+' sign
        let contactCellNib = UINib(nibName: "\(TMContactsCollectionViewCell.self)", bundle: nil)
        collectionView.register(contactCellNib, forCellWithReuseIdentifier: "\(TMContactsCollectionViewCell.self)")
        
        /// Location input
        collectionView.register(TMNewRequestLocationCollectionViewCell.self, forCellWithReuseIdentifier: "\(TMNewRequestLocationCollectionViewCell.self)")
        
        // Contacts info cell
        // Age + Relation information
        let contactInfoCellNib = UINib(nibName: "\(TMContactInfoCollectionViewCell.self)", bundle: nil)
        collectionView.register(contactInfoCellNib, forCellWithReuseIdentifier: "\(TMContactInfoCollectionViewCell.self)")
        
        // Price slider cell
        let priceSliderNib = UINib(nibName: "\(TMSliderCollectionViewCell.self)", bundle: nil)
        collectionView.register(priceSliderNib, forCellWithReuseIdentifier: "\(TMSliderCollectionViewCell.self)")
        
        // Request styles cell
        let stylesCellNib = UINib(nibName: "\(TMRequestStylesCollectionViewCell.self)", bundle: nil)
        collectionView.register(stylesCellNib, forCellWithReuseIdentifier: "\(TMRequestStylesCollectionViewCell.self)")
        
        // Request occasions cell
        let occasionCellNib = UINib(nibName: "\(TMOccasionCollectionViewCell.self)", bundle: nil)
        collectionView.register(occasionCellNib, forCellWithReuseIdentifier: "\(TMOccasionCollectionViewCell.self)")
        
        // Notes cell
        collectionView.register(TMRequestNotesCollectionViewCell.self, forCellWithReuseIdentifier: "\(TMRequestNotesCollectionViewCell.self)")
        
        // Button cell
        collectionView.register(TMRequestSubmitCollectionViewCell.self, forCellWithReuseIdentifier: "\(TMRequestSubmitCollectionViewCell.self)")

        return collectionView
    }()
    
    /// Navigation theme closure
    var navigationThemeHandler: ((NavigationTheme) -> Void)?
    
    // Scroll last direction - used for analytics
    var lastContentOffset: CGFloat = 0.0

    /// Attributes datasource
    lazy var occasionsArray: [TMRequestAttribute] = {
       
        /// Fetch occasions
        /// Soring by name
        return TMCoreDataManager.defaultStack.fetchAll(From<TMRequestAttribute>(),
                                                Where("category == %@", "occasion"),
                                                OrderBy(.ascending("name"))) ?? []
    }()
    
    /// Styles datasource
    var stylesArray: [TMRequestAttribute] = {
       
        /// Fetch styles
        /// Soring by name
        return TMCoreDataManager.defaultStack.fetchAll(From<TMRequestAttribute>(),
                                                                     Where("category == %@", "style"),
                                                                     OrderBy(.ascending("name"))) ?? []
    }()
    
    /// Interests datasource
    var interestsArray: [TMRequestAttribute] = {
        
        /// Fetch styles
        /// Soring by name
        return TMCoreDataManager.defaultStack.fetchAll(From<TMRequestAttribute>(),
                                                       Where("category == %@", "interest"),
                                                       OrderBy(.ascending("name"))) ?? []
    }()
    
    /// Style cell
    fileprivate var stylesCell: TMRequestStylesCollectionViewCell?
    
    /// Interest cell
    fileprivate var interestsCell: TMRequestStylesCollectionViewCell?

    
    /// Datasource Model
    var newRequestModel = NewRequestValidation()
    
    // MARK: - Init
    init() {
        
        super.init(nibName: nil, bundle: nil)
        
        /// Collection view
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        /// Collection view layout
        view.addConstraints([
            NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Controller lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Analytics
        TMAnalytics.trackScreenWithID(.s5)
        
        /// Disable keyboard
        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        /// Enable IQKeyboard
        IQKeyboardManager.sharedManager().enable = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        NotificationCenter.default.addObserver(self, selector: #selector(TMNewRequestViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TMNewRequestViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stylesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMRequestStylesCollectionViewCell.self)", for: IndexPath(row: 3, section: 0)) as? TMRequestStylesCollectionViewCell

        // Get styles array for dynamic size
        stylesCell?.stylesArray = stylesArray
        
        interestsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMRequestStylesCollectionViewCell.self)", for: IndexPath(row: 4, section: 0)) as? TMRequestStylesCollectionViewCell
        
        // Get interests array for dynamic size
        interestsCell?.stylesArray = stylesArray
        
        /// Set navigation bar theme
        updateNavigationBar(navigationTheme: .gray)
        
        /// Set navigation bar logo
        let logoImage: UIImage = TMLogo.imageOfLogo(CGSize(width: 80.0, height: 15.0), resizing: .aspectFit)
        let button = UIButton(x: 0.0, y: 0.0, w: 120, h: 33, target: self, action: #selector(TMNewRequestViewController.navigationBarButtonPressed))
        button.setImage(logoImage, for: .normal)
        button.setImage(logoImage, for: .highlighted)
        
        /// Back button setup
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: self, action: #selector(backButtonPressed))
        leftBarButtonItem.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        /// Add button to navigation view
        navigationItem.titleView = button
    }
    
    // MARK: - Submit Request
    fileprivate func onSubmitRequest()-> Promise<TMRequest?> {
        
        /// Check contacts validation
        /// Check request validation
        /// Transition on success
        
        /// Contact validation check
        return checkForContact().then { contact-> Promise<[String:Any]> in
            
            /// Update new request model
            self.newRequestModel.tokenContact = contact
            
            /// Validate params
            return TMNewRequestValidation.validateRequest(params: self.newRequestModel)
            
            }.then { params-> Promise<TMRequest?> in
                
                /// Validation success
                /// Create request
                return TMRequestAdapter.createRequest(params)
            }.then { request-> TMRequest? in
                
                return request
        }
    }
    
    private func checkForContact()-> Promise<TMContact?> {
        
        /// Safety check
        guard let tokenContact = newRequestModel.tokenContact else {
            /// Selected local/free form contact
            /// Validate data
            return TMNewRequestValidation.validateContact(params: newRequestModel).then { contactParams-> Promise<TMContact?> in
                
                /// Networking request 
                /// Create token contact
                return TMContactsAdapter.create(contactParams: contactParams)
            }
        }
        
        /// Token contact selected
        return Promise(value: tokenContact)
    }
    
    // MARK: - Actions
    @IBAction func navigationBarButtonPressed() {
        
        /// Scroll to Top
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
    
    override func backButtonPressed(_ sender: Any?) {
        
        super.backButtonPressed(sender)
        
        coordinatorDelegate?.onBackButton(self)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        var directionDict = [String: Any]()
        
        if lastContentOffset > scrollView.contentOffset.y {
            // up
            directionDict = ["label": "Up"]
        }
        else if lastContentOffset < scrollView.contentOffset.y {
            // down
            directionDict = ["label": "Down"]
        }
        
        TMAnalytics.trackEventWithID(.t_S5_1, eventParams: directionDict)
        
        lastContentOffset = scrollView.contentOffset.y
    }
    
    // MARK: - Keyboard logic
    func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            
            collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
    }
}

// MARK: - Submit cell delegate
extension TMNewRequestViewController: TMRequestSubmitCollectionViewCellDelegate {
    
    func onSubmitButton() {
        
        /// Show loading
        SVProgressHUD.show()
        
        /// Submit call
        /// Validated data
        /// Creates request from networking request
        onSubmitRequest().then { request-> Void in
            
            SVProgressHUD.dismiss()
            
            /// Analytics on success
            TMNewRequestAnalytics.trackNewRequest(request: request)
            
            /// Create confirmation VC
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let confirmationNavigationController = sb.instantiateViewController(withIdentifier: "confimationController") as? UINavigationController
            let confimationController = confirmationNavigationController?.topViewController as? TMConfirmedRequestViewController

            /// Assign created request
            confimationController?.request = request

            /// Present VC
            self.presentVC(confirmationNavigationController!)
            self.popToRootVC()
            
            }.catch { error in
                
                SVProgressHUD.dismiss()
                
                /// Show validatoin errors
                JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
}

// MARK: - Location delegate 
extension TMNewRequestViewController: TMNewRequestLocationCollectionViewCellDelegate {
    
    func locationDidEnter(text: String) {
        
        newRequestModel.location = text
    }
}

// MARK: - Price slider delegate
extension TMNewRequestViewController: TMSliderCollectionViewCellDelegate {
    
    func stepSliderScrolledToMinValue(_ minValue: Int, maxValue: Int) {
        
        /// Updating model
        newRequestModel.priceLow = minValue
        newRequestModel.priceHigh = maxValue
    }
}

// MARK: - Occasion free form delegate
extension TMNewRequestViewController: TMOccasionCollectionViewDelegate {
    
    func occasionSelected(_ occasion: TMRequestAttribute?) {
        
        /// When occasion selected scroll to section
        let occationIndexPath = IndexPath(item: 2, section: 0)
        collectionView.scrollToItem(at: occationIndexPath, at: .top, animated: true)
        
        newRequestModel.occasion = occasion
    }
    
    func freeFormTextChanged(_ text: String?) {
        
        /// Scroll
        let occationIndexPath = IndexPath(item: 2, section: 0)
        collectionView.scrollToItem(at: occationIndexPath, at: .top, animated: true)
        
        /// Free form selection
        newRequestModel.freeFormOccasion = text
    }
}

// MARK: - Details cell delegate
extension TMNewRequestViewController: TMRequestNotesCollectionViewCellProtocol {
    func textViewDidEndEditing(_ textView: UITextView) {
        
        newRequestModel.details = textView.text
    }
    
    func textNoteViewDidBeginEditing(_ textView: UITextView) {
        
        let requestDetailsIndexPath = IndexPath(item: 6, section: 0)
        collectionView.scrollToItem(at: requestDetailsIndexPath, at: .top, animated: true)
    }
    
    func textCaretPositionChanged(caretRect: CGRect, textView: UITextView) {
        
        var convertedCaretRect = collectionView.convert(caretRect, from: textView)
            
        let caretPadding: CGFloat = 50 //Padding at the bottom of the caret location, so when we scroll to the caret there is a little spacing underneath.
        convertedCaretRect.origin.y += caretPadding
        collectionView.scrollRectToVisible(convertedCaretRect, animated: true)
        
        newRequestModel.details = textView.text
    }
}

// MARK: - Contact selection delegate
extension TMNewRequestViewController: TMContactInfoCollectionViewCellDelegate {
    // Cross pressed
    func contactCrossButtonPressed(_ contact: CNContact?) {
        
        // Nullify selected contact
        newRequestModel.localContact = nil
        newRequestModel.tokenContact = nil
        newRequestModel.freeFormContact = nil
        
        // Reload contact cell
        collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
    }
    
    func freeFormRelationTextChanged(_ text: String) {
        
        newRequestModel.relation = text
    }
    
    func ageCellPressed(_ ageString: String) {
        
        newRequestModel.age = ageString
    }
    
    func relationCellPressed(_ relatoinString: String) {
        
        newRequestModel.relation = relatoinString
    }
    
    func genderCellPressed(_ genderString: String) {
        newRequestModel.gender = genderString.lowercased()
    }
}
    

// MARK: - TMRequestCellSizeProtocol
extension TMNewRequestViewController: TMRequestCellSizeProtocol {
    func sizeDidUpdate(_ indexPath: IndexPath) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - Styles Cell Delegate
extension TMNewRequestViewController: TMRequestStylesCollectionViewCellDelegate {
    func selectedStylesUpdated(cell: TMRequestStylesCollectionViewCell, _ styles: [TMRequestAttribute]) {
        if cell == stylesCell {
            /// Use only style IDs
            newRequestModel.style = styles.map{$0.id}
        } else {
            /// Use only style IDs
            newRequestModel.interests = styles.map{$0.id}
        }
    }
}

// MARK: - CollectionView Datasource
extension TMNewRequestViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TMNewRequestViewControllerCells.allData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.cellForItem(at: indexPath)
        
        /// Contact cell
        if indexPath.row == TMNewRequestViewControllerCells.contact.rawValue {
            
            /// Check if contact already selected
            if newRequestModel.freeFormContact == nil && newRequestModel.tokenContact == nil && newRequestModel.localContact == nil {
                
                let contactsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMContactsCollectionViewCell.self)", for: indexPath) as? TMContactsCollectionViewCell
                
                cell = contactsCell
            }
            else {
                let contactsSelectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMContactInfoCollectionViewCell.self)", for: indexPath) as! TMContactInfoCollectionViewCell
                
                /// Pass datasource
                contactsSelectedCell.contact = newRequestModel.localContact
                contactsSelectedCell.contactText = newRequestModel.freeFormContact
                contactsSelectedCell.existingContact = newRequestModel.tokenContact
                
                contactsSelectedCell.delegate = self
                
                cell = contactsSelectedCell
            }
        }
            /// Location cell
        else if indexPath.row == TMNewRequestViewControllerCells.location.rawValue {
            
            let locationCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMNewRequestLocationCollectionViewCell.self)", for: indexPath) as! TMNewRequestLocationCollectionViewCell
            locationCell.delegate = self
            
            cell = locationCell
        }
            /// Occasion cell
        else if indexPath.row == TMNewRequestViewControllerCells.occasion.rawValue {
            
            let occasionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMOccasionCollectionViewCell.self)", for: indexPath) as! TMOccasionCollectionViewCell
            
            occasionCell.dataSourceArray = occasionsArray
            occasionCell.delegate = self
            
            cell = occasionCell
        }
            /// Price cell
        else if indexPath.row == TMNewRequestViewControllerCells.price.rawValue {
            
            let sliderCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMSliderCollectionViewCell.self)", for: indexPath) as! TMSliderCollectionViewCell
            sliderCell.delegate = self
            
            cell = sliderCell
        }
            /// Style cell
        else if indexPath.row == TMNewRequestViewControllerCells.style.rawValue {
            
            let styleCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMRequestStylesCollectionViewCell.self)", for: indexPath) as! TMRequestStylesCollectionViewCell
            
            if styleCell.stylesArray.count != stylesArray.count {
                styleCell.stylesArray = stylesArray
                styleCell.contentSize = stylesCell?.contentSize
            }
            
            stylesCell = styleCell
            stylesCell?.titleLabel?.text = "RECIPIENT’S STYLE"
            stylesCell?.delegate = self
            
            cell = styleCell
        } else if indexPath.row == TMNewRequestViewControllerCells.interests.rawValue {
            let interestCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMRequestStylesCollectionViewCell.self)", for: indexPath) as! TMRequestStylesCollectionViewCell
            
            if interestCell.stylesArray.count != interestsArray.count {
                interestCell.stylesArray = interestsArray
                interestCell.contentSize = interestsCell?.contentSize
            }
            
            interestsCell = interestCell
            interestsCell?.titleLabel?.text = "RECIPIENT’S INTERESTS"
            interestsCell?.delegate = self
            
            cell = interestCell
        }
            /// Details cell
        else if indexPath.row == TMNewRequestViewControllerCells.details.rawValue {
            
            var requestNoteCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMRequestNotesCollectionViewCell.self)", for: indexPath) as? TMRequestNotesCollectionViewCell
            
            requestNoteCell?.placeholder = "Dogs, going to the beach, pampering, barware, etc."
            
            requestNoteCell?.delegate = self
            
            requestNoteCell?.title = "Other interests or thoughts"
            requestNoteCell?.subtitle = "optional"
            requestNoteCell?.indexPath = indexPath
            requestNoteCell?.sizeDelegate = self
            
            cell = requestNoteCell
        }
            /// Button cell
        else {
            
            let buttonCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMRequestSubmitCollectionViewCell.self)", for: indexPath) as! TMRequestSubmitCollectionViewCell
            
            buttonCell.backgroundColor = UIColor.clear
            buttonCell.delegate = self
            
            cell = buttonCell
        }
        
        /// Apply shadow to all cells except button
        if indexPath.row != TMNewRequestViewControllerCells.button.rawValue {
            cell?.addShadow()
        }
        
        return cell!
    }
}

// MARK: - CollectionView delegate
extension TMNewRequestViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /// Contact selection handler
        let cell = collectionView.cellForItem(at: indexPath) as? TMContactsCollectionViewCell
        if cell != nil {
            
            /// Contacts selection
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let contactsVC = sb.instantiateViewController(withIdentifier: "\(TMContactsSelectionViewController.self)") as! TMContactsSelectionViewController
            
            contactsVC.view.backgroundColor = view.backgroundColor
            navigationController?.pushViewController(contactsVC, animated: true)
        }
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension TMNewRequestViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellW = collectionView.frame.size.width - 22.0
        var cellH: CGFloat = 120.0
        
        /// Contact cell
        let contactText = newRequestModel.freeFormContact ?? ""
        /// Selected contact cell size
        if indexPath.row == TMNewRequestViewControllerCells.contact.rawValue && (newRequestModel.localContact != nil || contactText.length > 0 || newRequestModel.tokenContact != nil) {
            
            cellH = 420
        }
        
        /// Location cell
        if indexPath.row == TMNewRequestViewControllerCells.location.rawValue {
            
            cellH = 200.0
        }
        
        /// Occasion cell
        if indexPath.row == TMNewRequestViewControllerCells.occasion.rawValue {
            
            cellH = 260.0
        }
        
        /// Price cell
        if indexPath.row == TMNewRequestViewControllerCells.price.rawValue {
            
            cellH = 236.0
        }
        
        /// Styles cell
        if indexPath.row == TMNewRequestViewControllerCells.style.rawValue {
            
            guard let contentSize = stylesCell?.contentSize else {
                return CGSize(width: cellW, height: cellH)
            }
            
            return CGSize(width: cellW, height: contentSize.height)
        }
        
        /// Interests cell
        if indexPath.row == TMNewRequestViewControllerCells.interests.rawValue {
            
            guard let contentSize = interestsCell?.contentSize else {
                return CGSize(width: cellW, height: cellH)
            }
            
            return CGSize(width: cellW, height: contentSize.height)
        }
        
        
        /// Details cell
        if indexPath.row == TMNewRequestViewControllerCells.details.rawValue {
            cellH = TMRequestNotesCollectionViewCell.calculatedCellHeight(cellWidth: cellW, bodyViewData: newRequestModel.details ?? "", minHeight: 230)
        }
        
        /// Button cell
        if indexPath.row == TMNewRequestViewControllerCells.button.rawValue {
            
            cellH = 150
        }
        
        return CGSize(width: cellW, height: cellH)
    }
}
