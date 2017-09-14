//
//  TMAddressBookContactStatusView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 6/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Contacts

class TMAddressBookContactStatusView: TMContactStatusView {

    // Contact from addressBook
    var addressBookContact: CNContact? {
        didSet {
            // Safety check
            guard let _addressBookContact = addressBookContact else {
                return
            }
            
            self.resetView()
            
            // Setting text for full name label
            self.fullNameLabel.text = TMContact.getFullNameFrom(addressBookContact?.givenName, lastName: addressBookContact?.familyName)

            // Setting text color
            self.fullNameLabel.textColor = UIColor.black
            
            self.bowImageView.isHidden = false
            
            if let thumbnailImageData = _addressBookContact.thumbnailImageData {
                let thumbnail = UIImage(data: thumbnailImageData)
                
                bowImageView.image = thumbnail
            }
          
            else {
                
                self.setupWaxAvatar(name: self.fullNameLabel.text)
            }
        }
    }
}
