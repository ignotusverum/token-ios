//
//  TMContactName.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 12/19/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

extension TMContact {
    
    // First name if avaliable, if not show second name
    var availableName: String {
        
        let firstName = self.firstNameDisplay
        let lastName = self.lastNameDisplay
        
        if lastName == nil {
            
            if let firstName = firstName {
                return firstName
            }
            
            return ""
        }
        
        if firstName == nil {
            
            if let lastName = lastName {
                return lastName
            }
            
            return ""
        }
        else {
            
            return firstName!
        }
    }
    
    // Full name getter
    var fullName: String? {
        return TMContact.getFullNameFrom(self.firstNameDisplay, lastName: self.lastNameDisplay)
    }
    
    // First name initials getter
    var firstNameInitial: String? {
        return TMContact.getInitialsFromString(self.firstNameDisplay)
    }
    
    // Last name initials getter
    var lastNameInitial: String? {
        return TMContact.getInitialsFromString(self.lastNameDisplay)
    }
    
    // Utilities
    class func getInitialsFromString(_ string: String?)-> String {
        
        guard var _string = string, _string.length > 0 else {
            return ""
        }
        
        _string.capitalizeFirst()
        
        return _string[0].toString
    }
    
    class func getFullNameFrom(_ firstName: String?, lastName: String?)-> String {
        
        var fullNameString = ""
        
        if firstName != nil {
            
            fullNameString = fullNameString + firstName!
        }
        
        if lastName != nil {
            
            var additionalSpace = ""
            
            if firstName != nil {
                additionalSpace = " "
            }
            
            fullNameString = fullNameString + additionalSpace + lastName!
        }
        
        return fullNameString
    }
}
