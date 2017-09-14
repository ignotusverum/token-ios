//
//  TMContactView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/26/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Contacts

class TMContactView: UIView {
    
    // Contact Accessor
    var request: TMRequest? {
        didSet {
            guard let request = request else {
                return
            }
            
            // Setting text for full name label
            self.fullNameLabel.text = request.receiverNameDisplay
            
            self.bowImageView.isHidden = false
            
            // Showing bow image
            
            if let image = request.contact?.localContactImage {
                
                self.bowImageView.image = image
            }
            else {
                
                self.setupWaxAvatar(name: request.receiverNameDisplay)
            }
        }
    }
    
    var contact: TMContact? {
        didSet {
            guard let contact = contact else {
                return
            }
            
            // Setting text for full name label
            self.fullNameLabel.text = contact.fullName
            
            self.bowImageView.isHidden = false
            
            // Showing bow image
            
            if let image = contact.localContactImage {
                
                self.bowImageView.image = image
            }
            else {
                
                self.setupWaxAvatar(name: contact.availableName)
            }
        }
    }
    
    func setupWaxAvatar(name: String?) {
        
        guard let name = name else {
            
            bowImageView.image = UIImage(named: "default-wax")
            return
        }
        
        var availableName = name
        if availableName.length > 0 {
            availableName = "\(availableName[0])"
        }
        
        let sealName = "\(availableName.uppercased())-wax"
        
        if let image = UIImage(named: sealName) {
            
            bowImageView.image = image
        }
    }
    
    // Selected/Unselected State
    var selected = false {
        didSet {
            if selected {
                
                self.selectedCheckmarkImageView.isHidden = false
            }
            else {
                
                self.selectedCheckmarkImageView.isHidden = true
            }
        }
    }
    
    // Selected checkmark
    @IBOutlet var selectedCheckmarkImageView: UIImageView!
    
    // Initial view
    @IBOutlet var view: UIView!
    
    // Initials Base View
    @IBOutlet var containerView: UIView!
    
    // AB image
    var contactImage: UIImage?
    
    // Full Name label
    @IBOutlet var fullNameLabel: UILabel!
    
    // Bow image - if there's no one of initials
    @IBOutlet var bowImageView: UIImageView!
    
    // AddressBook logic - to get contact image, if it exists
    //fileprivate let addressBook = APAddressBook()
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if DeviceType.IS_IPHONE_6P {
            Bundle.main.loadNibNamed("TMContactViewPlus", owner: self, options: nil)
        }
        else {
            Bundle.main.loadNibNamed("TMContactView", owner: self, options: nil)
        }
        
        self.addSubview(view)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions.alignAllCenterY , metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions.alignAllCenterX , metrics: nil, views: ["view": self.view]))
    }
    
    // Custom initialization
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        
        self.containerView.layer.cornerRadius = self.containerView.bounds.width / 2.0
        self.containerView.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func customInit() {
        
        if DeviceType.IS_IPHONE_5 {
            
            self.fullNameLabel.font = UIFont.ActaMedium(14.0)
        }
    }
    
    // Reset
    func resetView() {
        
        self.bowImageView.image = UIImage(named: "default-wax")
    }
}
