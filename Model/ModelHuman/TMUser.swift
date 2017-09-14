//
//  TMUser.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON
import PromiseKit

/// Struct that represent User JSON keys
public struct TMUserJSON {
    
    static let profileImageURL = "profile_image_url"
    
    static let firstName = "first_name"
    static let lastName = "last_name"
    static let userName = "username"
    
    static let email = "email"
    static let phoneNumber = "phone_number"
}

@objc(TMUser)
open class TMUser: _TMUser {
    
    // Temporary user image
    var userImage: UIImage?
    
    // Cards Array
    var cardsArray: [TMPayment] {
        
        return self.cards.array as? [TMPayment] ?? []
    }
    
    // Addresses Array
    var addressesArray: [TMContactAddress] {
        
        return self.addresses.array as? [TMContactAddress] ?? []
    }
    
    // Full name getter
    var fullName: String {
        
        var fullNameString = ""
        
        if self.firstName != nil {
            
            fullNameString = fullNameString + self.firstName!
        }
        
        if self.lastName != nil {
            
            var additionalSpace = ""
            
            if self.firstName != nil {
                additionalSpace = " "
            }
            
            fullNameString = fullNameString + additionalSpace + self.lastName!
        }
        
        return fullNameString
    }
    
    // First name initials getter
    var firstNameInitial: String? {

        guard var firstName = self.firstName else {
            return ""
        }
        
        firstName.capitalizeFirst()
        
        return firstName[0].toString
    }
    
    // Last name initials getter
    var lastNameInitial: String? {

        guard var lastName = self.lastName else {
            return ""
        }
        
        lastName.capitalizeFirst()
        
        return lastName[0].toString
    }
    
    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        try super.updateModel(with: source, transaction: transaction)
        
        // Profile image URL
        self.profileURLString = source[TMUserJSON.profileImageURL].string
        
        // Email
        self.email = source[TMUserJSON.email].string
        
        // First name
        self.firstName = source[TMUserJSON.firstName].string
        
        // Last name
        self.lastName = source[TMUserJSON.lastName].string
        
        // Username - Used in chat
        self.userName = source[TMUserJSON.userName].string
        
        // Phone formatted - e164
        self.phoneNumberFormatted = source[TMUserJSON.phoneNumber].phone
        
        // Phone raw
        self.phoneNumberRaw = source[TMUserJSON.phoneNumber].string
    }
}
