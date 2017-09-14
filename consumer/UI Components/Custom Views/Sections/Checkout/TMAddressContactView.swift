//
//  TMAddressContactView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/17/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMAddressContactView: TMContactView {

    // User View
    var user: TMUser? {
        didSet {
            
            guard let _user = user else {
                return
            }
            
            // Setting text for full name label
            self.fullNameLabel.text = _user.fullName
            
            self.bowImageView.isHidden = false
            
            if let profileImageURL = _user.profileURLString {
                
                bowImageView.downloadImageFrom(link: URL(string: profileImageURL), contentMode: .scaleAspectFill)
            }
            else {
                
                self.setupWaxAvatar(name: _user.fullName)
            }
        }
    }
}
