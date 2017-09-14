//
//  TMNewPaymentViewController.swift
//  consumer
//
//  Created by Gregory Sapienza on 3/10/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import JDStatusBarNotification
import SVProgressHUD

/// State of the TMAddCreditCardPaymentViewController
///
/// - normal: Normal viewing state.
/// - editingPaymentField: Currently editing a text field.
/// - scanningCreditCard: Scanning a credit card with camera.
/// - cancelingCreditCardScan: When cancelling the action of scanning a credit card.
/// - savingCreditCardInfo: When saving a credit card.
private enum TMAddCreditCardPaymentViewControllerState {
    case normal
    case editingPaymentField(fieldIndexPath: IndexPath)
    case scanningCreditCard
    case cancelingCreditCardScan(viewController: UIViewController)
    case savingCreditCardInfo
}

class TMAddCreditCardPaymentViewController: UIViewController {

    // MARK: - Private iVars

    /// Main collection view with payment fields.
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = TMAddCreditCardPaymentCollectionViewLayout()

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(TMAddCreditCardPaymentCollectionViewCell.self, forCellWithReuseIdentifier: "\(TMAddCreditCardPaymentCollectionViewCell.self)")
        collectionView.register(TMScanCreditCardPaymentCollectionViewCell.self, forCellWithReuseIdentifier: "\(TMScanCreditCardPaymentCollectionViewCell.self)")
        
        return collectionView
    }()
    
    /// Theme for view controller to display.
    fileprivate let theme: TMAddCreditCardPaymentTheme
    
    /// Action to call when a save was successful.
    var saveAction: () -> Void
    
    /// State of the view controller.
    fileprivate var state: TMAddCreditCardPaymentViewControllerState = .editingPaymentField(fieldIndexPath: IndexPath(item: 0, section: 0))
    
    /// Model for view controller.
    fileprivate var model = TMAddCreditCardModel()
    
    // MARK: - Public
    
    init(theme: TMAddCreditCardPaymentTheme, saveAction: @escaping () -> Void = {  }) {
        self.theme = theme
        self.saveAction = saveAction
        super.init(nibName: nil, bundle: nil)
    }
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---View---//
        
        view.backgroundColor = theme.backgroundColor()
        
        //---Collection View---//
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(
            [NSLayoutConstraint(item: collectionView, attribute: .topMargin, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .bottomMargin, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0)]
        )
        
        //---Navigation Item---//
        
        addTitleText("ADD A CREDIT CARD", color: theme.navigationTintColor())
        
        navigationController?.navigationBar.tintColor = theme.navigationTintColor()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backButton"), style: .plain, target: self, action: #selector(onBackButton)) //Back button
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        stateDidChange() //Set the initial state.
        CardIOUtilities.preloadCardIO() //Preloads camera when scanning credit card. Recommended on framework page.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        view.endEditing(true)
        
        switch state {
        case let .editingPaymentField(fieldIndexPath):
            if let cell = collectionView.cellForItem(at: fieldIndexPath) as? TMAddCreditCardPaymentCollectionViewCell {
                cell.textField.resignFirstResponder()
            }
        default:
            break
        }
    }
    
    // MARK: - Private
    
    fileprivate func stateDidChange() {
        switch state {
        case .normal:
            break
        case let .editingPaymentField(indexPath):
            
            //Sets the text field in the cell to be active.
            if let cell = collectionView.cellForItem(at: indexPath) as? TMAddCreditCardPaymentCollectionViewCell {
                let _ = cell.textField.becomeFirstResponder()
            }
        case .scanningCreditCard:
            
            //Presents view controller to start scanning credit card.
            if let cardCameraViewController = CardIOPaymentViewController(paymentDelegate: self) {
                cardCameraViewController.modalPresentationStyle = .overFullScreen
                modalPresentationCapturesStatusBarAppearance = true
                present(cardCameraViewController, animated: true, completion: nil)
            }
        case let .cancelingCreditCardScan(viewController):
            
            //Dismisses credit card scan view controller provided.
            viewController.dismiss(animated: true, completion: nil)
        case .savingCreditCardInfo:
            SVProgressHUD.show()
        }
    }

    // MARK: - Actions
    
    /// Action when the user taps the back button in the navigation bar.
    @objc private func onBackButton() {
        let _ = navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension TMAddCreditCardPaymentViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return TMAddCreditCardPaymentDataType.displaySections().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TMAddCreditCardPaymentDataType.displaySections()[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Add credit card cell
        guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMAddCreditCardPaymentCollectionViewCell.self)", for: indexPath) as? TMAddCreditCardPaymentCollectionViewCell else {
            fatalError("Cell is incorrect type.")
        }
        
        //If name cell, use the special scan credit card cell that contains a scan button.
        switch model.paymentField(for: indexPath) {
        case .name:
            if let scanCell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TMScanCreditCardPaymentCollectionViewCell.self)", for: indexPath) as? TMScanCreditCardPaymentCollectionViewCell {
                cell = scanCell
                scanCell.scanDelegate = self
            }
        default:
            break
        }
        
        let paymentField = model.paymentField(for: indexPath) //Field type.
        
        cell.paymentField = paymentField
        cell.theme = theme
        cell.indexPath = indexPath
        cell.delegate = self
        
        if let text = model.paymentData(for: paymentField) {
            let creditCardType = model.creditCardBrandFromPaymentData()
            cell.textField.text = paymentField.textDecoratorHandler(text: text, cardType: creditCardType)
        }
        
        if indexPath.item != collectionView.numberOfItems(inSection: indexPath.section) - 1 { //Display right side border on every cell except the last in a section.
            cell.displaySideBorder = true
        }
        
        return cell
    }
}

// MARK: - TMAddCreditCardPaymentCollectionViewCellProtocol
extension TMAddCreditCardPaymentViewController: TMAddCreditCardPaymentCollectionViewCellProtocol {
    func allTextFieldsVerified() -> Bool {
        return model.allFieldTypesVerified() //If all text fields have the required amount of information.
    }
    
    func textEditingBeganForIndexPath(_ indexPath: IndexPath) {
        state = .editingPaymentField(fieldIndexPath: indexPath)
    }
    
    func nextButtonTappedForIndexPath(_ indexPath: IndexPath) {
        let nextItemIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
        let nextSectionIndexPath = IndexPath(item: 0, section: indexPath.section + 1)
        
        if model.paymentFields(for: nextItemIndexPath.section).indices.contains(nextItemIndexPath.item) { //If there is a next item in the section then make that the first responder.
            state = .editingPaymentField(fieldIndexPath: nextItemIndexPath)
        } else if model.paymentFieldSections().indices.contains(nextSectionIndexPath.section) { //If there is no next item in the section, but another section then make the first item in the next section the first responder.
            state = .editingPaymentField(fieldIndexPath: nextSectionIndexPath)
        }
        
        stateDidChange()
    }
    
    func textFieldDidChange(indexPath: IndexPath, newString: String) {
        let paymentField = model.paymentField(for: indexPath)
        
        model.setPaymentData(newString, for: paymentField) //Updates the backing payment data.
        
        let creditCardType = model.creditCardBrandFromPaymentData()
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TMAddCreditCardPaymentCollectionViewCell {
            cell.textField.text = paymentField.textDecoratorHandler(text: newString, cardType: creditCardType) //Decorates the text for use in the text field.
        }
        
        if model.fieldVerified(for: paymentField) && !paymentField.allowsTextAfterVerification() {
            nextButtonTappedForIndexPath(indexPath) //If the field is verified and good to go and we dont allow for further input after verification.
        }
    }
    
    func onSaveButton() {
        state = .savingCreditCardInfo
        stateDidChange()
        
        //Saves credit card. Presents an error message if there was an issue. Save action is called if successful.
        model.saveCreditCardFromPaymentData { (error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    self.state = .editingPaymentField(fieldIndexPath: IndexPath(item: 0, section: 0))
                    SVProgressHUD.dismiss()
                    JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                } else {
                    self.state = .normal
                    SVProgressHUD.dismiss(completion: {
                        self.saveAction()
                    })
                }
                
                self.stateDidChange()            
            }
        }
    }
    
    func shouldChangeCharacters(_ indexPath: IndexPath, text: String) -> Bool {
        let paymentField = model.paymentField(for: indexPath)
        
        return !model.fieldVerified(for: paymentField) || paymentField.allowsTextAfterVerification()  //If text field has not been verified then editing is OK. Or we allow for more text after verification for this field.
    }
}

// MARK: - TMScanCreditCardPaymentCollectionViewCellProtocol
extension TMAddCreditCardPaymentViewController: TMScanCreditCardPaymentCollectionViewCellProtocol {
    func scanControlTapped() {
        state = .scanningCreditCard
        stateDidChange()
    }
}

// MARK: - CardIOPaymentViewControllerDelegate
extension TMAddCreditCardPaymentViewController: CardIOPaymentViewControllerDelegate {
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        
        model.importScannedCreditCardData(from: cardInfo) //Imports the data from the reader.
        
        collectionView.reloadData()

        //State is set twice because we want to dismiss the view controller but we also want to set a text field as the first responder.
        state = .cancelingCreditCardScan(viewController: paymentViewController)
        stateDidChange()
        
        state = .editingPaymentField(fieldIndexPath: IndexPath(item: 0, section: 0))
        stateDidChange()
    }
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        state = .cancelingCreditCardScan(viewController: paymentViewController)
        stateDidChange()
        
        state = .editingPaymentField(fieldIndexPath: IndexPath(item: 0, section: 0))
        stateDidChange()
    }
}
