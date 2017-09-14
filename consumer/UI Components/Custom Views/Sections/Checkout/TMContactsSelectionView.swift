//
//  TMContactsSelectionView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/16/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//


protocol TMContactsSelectionViewDelegate {
    func contactButtonPressed()
    func currentUserButtonPressed()
}

class TMContactsSelectionView: UIView {
    
    // Delegate
    var delegate: TMContactsSelectionViewDelegate?
    
    // Main View
    @IBOutlet var view: UIView!
    
    // Request Contact
    var contact: TMContact? {
        didSet {
            
            self.requestContactView?.contact = contact
            
            // Assigning delegate methods
            self.requestContactView?.delegate = self
            
            guard let contact = contact else {
                return
            }
            
            // Setting name
            requestContactView?.contactView?.fullNameLabel.text = "Ship to \(contact.availableName)"
        }
    }
    
    // Current Contact
    var currentContact: TMUser? {
        didSet {
            
            self.currentContactView?.user = currentContact
            
            // Assigning delegate methods
            self.currentContactView?.delegate = self
            
            // Setting name
            currentContactView?.contactView?.fullNameLabel.text = "Ship to Me"
        }
    }
    
    // Request Contact View
    @IBOutlet fileprivate var requestContactView: TMContactButtonView?
    
    // Current Contact View
    @IBOutlet fileprivate var currentContactView: TMCurrentProfileButtonView?
    
    // Custom init with same-name-nib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("TMContactsSelectionView", owner: self, options: nil)
        self.addSubview(view)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions.alignAllCenterY , metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions.alignAllCenterX , metrics: nil, views: ["view": self.view]))
        
        self.currentContactView?.selected = true
        self.requestContactView?.selected = false
    }
    
    func toggleContactViews() {
        
        self.currentContactView!.selected = !self.currentContactView!.selected
        self.requestContactView!.selected = !self.requestContactView!.selected
    }
    
    // Contact selection methods
    func pressContact(_ contact: TMContact?) {
        
        self.currentContactView?.selected = false
        self.requestContactView?.selected = true
        
        delegate?.contactButtonPressed()
    }
    
    func pressCurrentUser() {
        
        self.currentContactView?.selected = true
        self.requestContactView?.selected = false
        
        delegate?.currentUserButtonPressed()
    }
}

// Contacts Button delegate method
extension TMContactsSelectionView: TMContactButtonViewDelegate {
    func contactButtonPressed(_ contact: TMContact?) {
        
        self.pressContact(contact)
    }
    
    func currentProfileButtonPressed() {
        
        self.pressCurrentUser()
    }
}
