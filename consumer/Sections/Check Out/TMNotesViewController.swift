//
//  TMNotesViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/31/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import PromiseKit
import SVProgressHUD
import EZSwiftExtensions
import JDStatusBarNotification

enum NoteValidationError: String {
    
    case Note = "Wrong Note text"
    case ToForm = "Wrong To text"
    case FromForm = "Wrong From text"
    
    case Success = "Success"
}

class TMNotesViewController: UIViewController {
    
    // Request Object
    var request: TMRequest?
    
    // Collection View
    @IBOutlet var collectionView: UICollectionView!
    
    fileprivate lazy var nextButton: UIButton = {
        let button = UIButton.button(style: .alternateBlack)
        
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(onNextButton), for: .touchUpInside)
        
        return button
    }()
    
    /// Notes next button pressed
    var onNextButtonSelection: (() -> ())?
    
    // TextFields
    var giftNoteTextView: UITextView?
    
    var toNoteTextField: UITextField?
    var fromNoteTextField: UITextField?
    
    var notesString = String()

    
    // Controller lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Analytics
        TMAnalytics.trackScreenWithID(.s12)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = view.backgroundColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitleText("WRITE A NOTE")
        
        let orderNoteCellNib = UINib(nibName: "TMOrderNoteCollectionViewCell", bundle: nil)
        
        collectionView.register(orderNoteCellNib, forCellWithReuseIdentifier: "TMOrderNoteCell")
        
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 66.0, right: 0.0)
        
        // Custom ui setup
        ez.runThisAfterDelay(seconds: 0.1) {
            self.customUISetup()
        }
        
        if let note = request?.cart?.label?.note {
            notesString = note
        }
        
        customUISetup()
        view.addSubview(collectionView)
        
        view.addSubview(nextButton)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            NSLayoutConstraint(item: nextButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: nextButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: nextButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: nextButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 66)
            ])
    }
    
    func customUISetup() {
        
        if let toNote = request?.cart?.label?.to {
            
            toNoteTextField?.text = toNote
        }
        
        if let fromNote = request?.cart?.label?.from {
            
            fromNoteTextField?.text = fromNote
        }
        else {
            let config = TMConsumerConfig.shared
            let user = config.currentUser
            
            if let user = user {
                
                fromNoteTextField?.text = user.fullName
            }
        }
        
        if let note = request?.cart?.label?.note {
            
            giftNoteTextView?.text = note
            notesString = note            
        }
    }
    
    // Actions
    override func backButtonPressed(_ sender: Any?) {
        popVC()
    }
    
    // Next Button pressed
    func onNextButton(_ sender: Any) {
        let validationResult = validateNote()
        
        var noteExists = false
        if let giftNoteText = giftNoteTextView?.text, giftNoteText.length > 0 {
            noteExists = true
        }
        
        guard let contact = request?.contact else {
            
            JDStatusBarNotification.show(withStatus: "error 501: Whoops, something went wrong, please try again later.", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            return
        }
        
        // Analytics
        TMAnalytics.trackEventWithID(.t_S12_0, eventParams: ["note": noteExists])
        
        if validationResult != .Success {
            JDStatusBarNotification.show(withStatus: validationResult.rawValue, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
        else {
            
            if let toNote = toNoteTextField?.text, let fromNote = fromNoteTextField?.text, let noteText = giftNoteTextView?.text {
                
                let labelParams = ["to": toNote, "from": fromNote, "message": noteText]
                
                SVProgressHUD.show()
                
                TMCartAdapter.setLabel(cart: request?.cart, labelParams: labelParams).then { response-> Promise<[TMShippingType]> in
                    
                    return TMShippingAdapter.fetch()
                    }.then { response-> Promise<TMContact?> in
                        
                        return TMContactsAdapter.fetch(contactID: contact.id)
                    }.then { response-> Void in
                
                        SVProgressHUD.dismiss()
                        
                        /// Order details flow selection
                        /// Checking if block used
                        guard let onNextButtonSelection = self.onNextButtonSelection else {
                            
                            self.performSegue(withIdentifier: "addressSegue", sender: nil)
                            
                            return
                        }
                        
                        onNextButtonSelection()
                        self.popVC()

                    }.catch { error in
                    
                        SVProgressHUD.dismiss()
                        JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                }
            }
        }
    }
    
    // Utilities
    // Validate CC Info
    func validateNote()-> NoteValidationError {
        
        guard let _toFormText = toNoteTextField?.text else {
            return .ToForm
        }
        
        if _toFormText.length < 1 {
            return .ToForm
        }
        
        guard let _fromFormText = fromNoteTextField?.text else {
            return .FromForm
        }
        
        if _fromFormText.length < 1 {
            return .FromForm
        }
        
        return .Success
    }
    
    // Segue overriding
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextController = segue.destination as? TMShippingInformationViewController
        nextController?.request = request
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension TMNotesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellW = collectionView.frame.size.width - 22.0
        var cellH: CGFloat = 210
        
        if indexPath.item == 1 {
            cellH = TMRequestNotesCollectionViewCell.calculatedCellHeight(cellWidth: cellW, bodyViewData: notesString, minHeight: 210)
        }
        
        return CGSize(width: cellW, height: cellH)
    }
}

// MARK: - CollectionView Datasource
extension TMNotesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.cellForItem(at: indexPath)
        
        if cell == nil {
            
            if indexPath.row == 0 {
                
                let noteOrderCell = collectionView.dequeueReusableCell(withReuseIdentifier:"TMOrderNoteCell", for: indexPath) as! TMOrderNoteCollectionViewCell
                
                noteOrderCell.request = request
                
                toNoteTextField = noteOrderCell.receiverTextField
                
                fromNoteTextField = noteOrderCell.senderTextField
                
                cell = noteOrderCell
            }
            else {
                
                var noteCell = collectionView.dequeueReusableCell(withReuseIdentifier:"TMNoteCell", for: indexPath) as! TMRequestNotesCollectionViewCell
                
                var nameText = "them"
                
                if let _text = request?.contact?.availableName {
                    nameText = _text
                }
                
                noteCell.title = "Handwritten Note"
                noteCell.indexPath = indexPath
                noteCell.sizeDelegate = self
                noteCell.delegate = self
                noteCell.placeholder = "Why are you giving this gift?\nTell \(nameText)!"
                
                giftNoteTextView = noteCell.bodyView
                
                
                
                cell = noteCell
            }
        }
        
        cell?.addShadow()
        cell?.clipsToBounds = false
        
        cell?.contentView.frame = (cell?.bounds)!
        cell?.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return cell!
    }
}

// MARK: - TMRequestNotesCollectionViewCellProtocol
extension TMNotesViewController: TMRequestNotesCollectionViewCellProtocol {
    func textCaretPositionChanged(caretRect: CGRect, textView: UITextView) {
        if var convertedCaretRect = collectionView?.convert(caretRect, from: textView) {
            let caretPadding: CGFloat = 50 //Padding at the bottom of the caret location, so when we scroll to the caret there is a little spacing underneath.
            convertedCaretRect.origin.y += caretPadding
            collectionView?.scrollRectToVisible(convertedCaretRect, animated: true)
            
            notesString = textView.text
        }
    }
}

// MARK: - TMRequestCellSizeProtocol
extension TMNotesViewController: TMRequestCellSizeProtocol {
    func sizeDidUpdate(_ indexPath: IndexPath) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}
