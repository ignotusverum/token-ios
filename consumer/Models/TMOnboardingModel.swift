//
//  TMOnboardingModel.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/7/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

// MARK: - Error State Enums
// Enums for error state
public enum TMOnboardingErrorState {
    
    case firstName, lastName, email, password, phone
}

class TMOnboardingModel: NSObject, NSCoding {
    
    // MARK: - Properties
    
    var firstName: String?
    var lastName: String?
    
    var email: String?
    var password: String?
    
    var phone: String?
    var phoneInternational: String? {
        
        guard let phone = self.phone, let countryString = countryString else {
            return nil
        }
        
        do {
            
            let phoneNumberKit = PhoneNumberKit()
            let phoneNumber = try phoneNumberKit.parse(phone, withRegion: countryString)
            
            let international = phoneNumberKit.format(phoneNumber, toType: .e164)
            
            return international
        } catch { }
        
        return nil
    }
    
    var countryString: String?
    
    // Types of validation error
    
    var validationErrors: [TMOnboardingErrorState] = [.firstName, .lastName, .email, .password, .phone]
    
    // MARK: - Transform Dict
    
    var dictionary: [String: Any]? {
        
        var resultDict = [String: Any]()
        
        resultDict["email"] = self.email
        resultDict["phone_number"] = self.phoneInternational
        
        resultDict["last_name"] = self.lastName
        resultDict["first_name"] = self.firstName
        
        
        resultDict["password"] = self.password
        
        return resultDict
    }
    
    // Validation check bool
    
    var validationCheck: Bool {
        
        if self.validationErrors.count > 0 {
            
            return false
        }
        
        return true
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        let firstName = aDecoder.decodeObject(forKey: "firstName") as? String
        let lastName = aDecoder.decodeObject(forKey: "lastName") as? String
        
        let email = aDecoder.decodeObject(forKey: "email") as? String
        
        let phone = aDecoder.decodeObject(forKey: "phone") as? String
        
        let password = aDecoder.decodeObject(forKey: "password") as? String
        
        let countryString = aDecoder.decodeObject(forKey: "countryString") as? String
        
        self.init(firstName: firstName, lastName: lastName, email: email, phone: phone, password: password, countryString: countryString)
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        
        aCoder.encode(email, forKey: "email")
        
        aCoder.encode(phone, forKey: "phone")
        
        aCoder.encode(password, forKey: "password")
        
        aCoder.encode(countryString, forKey: "countryString")
    }
    
    init(firstName: String?, lastName: String?, email: String?, phone: String?, password: String?, countryString: String?) {
        
        self.firstName = firstName
        self.lastName = lastName
        
        self.email = email
        
        self.password = password
        
        self.phone = phone
        self.countryString = countryString
        
        if firstName != nil && TMInputValidation.isValidName(firstName) {
            
            self.validationErrors.removeFirst(.firstName)
        }
        
        if lastName != nil && TMInputValidation.isValidName(lastName) {
            
            self.validationErrors.removeFirst(.lastName)
        }
        
        if email != nil && TMInputValidation.isValidEmail(email) {
            
            self.validationErrors.removeFirst(.email)
        }
        
        if phone != nil && countryString != nil && TMInputValidation.isValidPhone(phone, countryCode: countryString) {
            
            self.validationErrors.removeFirst(.phone)
        }
        
        if password != nil && TMInputValidation.isValidPassword(password) {
            
            self.validationErrors.removeFirst(.password)
        }
    }
    
    func validateObject(_ object: String?, validationFunction:(String?)-> Bool)-> Bool {
        
        return false
    }
}
