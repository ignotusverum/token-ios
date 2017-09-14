//
//  TMContactButtonView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/16/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

protocol TMContactButtonViewDelegate {
    func contactButtonPressed(_ contact: TMContact?)
    func currentProfileButtonPressed()
}

class TMContactButtonView: UIView {

    // Selected/Unselected State
    var selected = false {
        didSet {
            if selected {
                
                self.contactView?.fullNameLabel.textColor = UIColor.black
            }
            else {
                
                self.contactView?.fullNameLabel.textColor = UIColor.gray
            }
            
            self.contactView?.selected = selected
        }
    }
    
    @IBOutlet var selectedCheckmarkImageView: UIImageView!
    
    // Delegate
    var delegate: TMContactButtonViewDelegate?
    
    // Contact Object
    var contact: TMContact? {
        didSet {
            // Safety check
            guard let _contact = contact else {
                return
            }
            
            // Updating contact view
            self.contactView?.contact = _contact
        }
    }
    
    // Initial view
    @IBOutlet var view: UIView!
    
    // Contact View - image + name
    var contactView: TMAddressContactView?
    
    // Custom init with same-name-nib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("TMContactButtonView", owner: self, options: nil)
        self.addSubview(view)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions.alignAllCenterY , metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions.alignAllCenterX , metrics: nil, views: ["view": self.view]))
    }
    
    // Calling contact pressed delegate method
    @IBAction func contactButtonPressed(_ sender: AnyObject) {
        self.delegate?.contactButtonPressed(self.contact)
    }
}
