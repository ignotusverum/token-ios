//
//  TMInputValidation.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/7/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Stripe

class TMInputValidation: NSObject {
    
    class func isValidEmail(_ email: String?)-> Bool {
        
        guard let email = email else {
            
            return false
        }
        
        let emailString = email.NoWhiteSpace
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluate(with: emailString)
        
        return result
    }
    
    
    class func isValidPhone(_ phone: String?, countryCode: String?)-> Bool {
        
        guard let phone = phone, let countryCode = countryCode else {
            
            return false
        }
        
        do {
            
            let phoneNumberKit = PhoneNumberKit()
            
            let _ = try phoneNumberKit.parse(phone, withRegion: countryCode)
            
            return true
        }
        catch {
            return false
        }
    }
    
    class func isValidPostalCode(_ postalCode: String?)-> Bool {
        
        guard let postalCode = postalCode, postalCode.length > 2 else {
            
            return false
        }
        
        return true
    }
    
    class func isValidPassword(_ password: String?)-> Bool {
        
        guard let password = password, password.length >= 8 else {
            
            return false
        }
        
        return true
    }
    
    class func isValidCreditCardNumber(_ cardNumber: String?)-> Bool {
        
        guard let cardNumber = cardNumber, STPCardValidator.validationState(forNumber: cardNumber, validatingCardBrand: true) == .valid else {
            
            return false
        }
        
        return true
    }
    
    class func isValidCVC(_ cvc: String?, forCardBrand cardBrand: STPCardBrand)-> Bool {
        
        guard let cvc = cvc, STPCardValidator.validationState(forCVC: cvc, cardBrand: cardBrand) == .valid else {
            
            return false
        }
        
        return true
    }
    
    class func isValidCardExpirationYear(_ year: String?, month: String?)-> Bool {
        
        guard let year = year, let month = month, STPCardValidator.validationState(forExpirationYear: year, inMonth: month) == .valid else {
            
            return false
        }
        
        return true
    }
    
    class func isValidName(_ name: String?)-> Bool {
        
        if let name = name, name.length > 0 {
            return true
        }
        
        return false
    }
    
    class func containsSpecialCharacters(_ string: String)-> Bool {
        
        let characterset = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789")
        if string.rangeOfCharacter(from: characterset.inverted) != nil {
            return true
        }
        
        return false
    }
}
