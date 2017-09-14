//
//  TMNewRequestValidation.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/20/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Contacts
import PromiseKit

/// Request Validation Errors
enum NewRequestValidationError: Error {
    
    case contact
    case gender
    case age
    case relation
    case location
    case occasion
    case style
    case interests
}

extension NewRequestValidationError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .contact:
            return "Please select a contact"
            
        case .gender:
            return "Please select recipient's gender"
            
        case .age:
            return "Please select age"
            
        case .relation:
            return "Please select relation"
            
        case .location:
            return "Please enter the recipient's location"
            
        case .occasion:
            return "Please choose an occasion"
            
        case .style:
            return "Please select style"
            
        case .interests:
            return "Please select interests"
        }
    }
}

public struct NewRequestValidationJSON {
    
    static let userID = "user_id"
    static let contactID = "contact_id"
    
    static let attributes = "attributes"
    static let interests = "interests"
    static let occasion = "occasion"
    
    static let receiverName = "receiver_name"
    
    static let age = "age"
    static let location = "location"
    static let relation = "relation"
    static let gender = "gender"
    
    static let description = "description"
    
    static let priceLow = "price_low"
    static let priceHigh = "price_high"
}

/// Request validation struct
struct NewRequestValidation {
    
    /// Request object for pre-selection
    var request: TMRequest?
    
    /// New Request properties
    
    /// Contact cell
    var relation: String = "Friend"
    var age: String = "25 - 34"
    var gender: String = "male"
    
    /// Contact can be one of tree types
    var tokenContact: TMContact? {
        didSet {
            
            /// Safety check
            guard let _ = tokenContact else {
                return
            }
            
            /// Invalidate other contacts
            localContact = nil
            freeFormContact = nil
        }
    }
    
    var localContact: CNContact? {
        didSet {
            
            /// Safety check
            guard let _ = localContact else {
                return
            }
            
            /// Invalidate other contacts
            tokenContact = nil
            freeFormContact = nil
        }
    }
    
    var freeFormContact: String? {
        didSet {
            
            /// Safety check
            guard let _ = freeFormContact else {
                return
            }
            
            /// Invalidate other contacts
            tokenContact = nil
            localContact = nil
        }
    }
    
    /// Location
    var location: String?
    
    /// Occasion
    var occasion: TMRequestAttribute? {
        didSet {
            
            // Safety check
            guard let _ = occasion else {
                return
            }
            
            // Invalidate free form
            freeFormOccasion = nil
        }
    }
    
    var freeFormOccasion: String? {
        didSet {
            
            // Safety check
            guard let _ = freeFormOccasion else {
                return
            }
            
            // Invalidate occasion
            occasion = nil
        }
    }
    
    /// Price, with default values
    var priceHigh: Int = 200
    var priceLow: Int = 100
    
    /// Style
    var style: [String]?
    
    var interests: [String]?
    
    /// Details
    var details: String?
}

class TMNewRequestValidation {
    
    /// Validation
    class func validateRequest(params: NewRequestValidation)-> Promise<[String:Any]> {
        
        var result: [String: Any] = [:]
        
        /// Current user id
        let config = TMConsumerConfig.shared
        result[NewRequestValidationJSON.userID] = config.currentUser!.id
        
        /// Validate in order
        /// Validate token contact
        return tokenContact(params.tokenContact).then { tokenContact-> Promise<String> in
            
            /// Token contact validated
            result[NewRequestValidationJSON.contactID] = tokenContact.id
            
            /// Price
            result[NewRequestValidationJSON.priceLow] = params.priceLow
            result[NewRequestValidationJSON.priceHigh] = params.priceHigh
            
            /// Description
            result[NewRequestValidationJSON.description] = params.details
            
            result[NewRequestValidationJSON.gender] = params.gender
            
            return gender(params.gender)
            }.then { genderString -> Promise<String> in
                
            /// Age validation
            return age(params.age)
            }.then { ageString-> Promise<String> in
                
                /// Age validated
                result[NewRequestValidationJSON.age] = ageString
                
                /// Relation validation
                return relation(params.relation)
            }.then { relationString-> Promise<String> in
                
                /// Relation validated
                result[NewRequestValidationJSON.relation] = relationString
                
                /// Location validation
                return location(params.location)
            }.then { locationString-> Promise<(occasionName: String, attributeID: String)> in
                
                /// Location validated
                result[NewRequestValidationJSON.location] = locationString
                
                /// Validate request attributes
                return occasion(params.occasion)
            }.recover { error-> Promise<(occasionName: String, attributeID: String)> in
                
                /// Only handle occasion error here
                guard let _error = error as? NewRequestValidationError, _error == .occasion else { throw error }
                
                /// Occasion field is not selected
                /// Validating free form field
                return occasionFreeForm(params.freeFormOccasion)
            }.then { occasionName, attributeID-> Promise<[String]> in
                
                /// Occasion validated
                result[NewRequestValidationJSON.occasion] = occasionName
                result[NewRequestValidationJSON.attributes] = [attributeID]
                
                /// Validate styles
                return styles(params.style)
            }.then { styles-> Promise<[String]> in
                
                /// Styles validated
                var attributesArray = result[NewRequestValidationJSON.attributes] as! [String]
                attributesArray.append(contentsOf: styles)
                result[NewRequestValidationJSON.attributes] = attributesArray
                
                return interests(params.interests)
            }.then { interests-> [String:Any] in
                
                /// Styles validated
                var attributesArray = result[NewRequestValidationJSON.attributes] as! [String]
                attributesArray.append(contentsOf: interests)
                result[NewRequestValidationJSON.attributes] = attributesArray
                
                return result
        }
    }
    
    // MARK: - Contact validation
    class func validateContact(params: NewRequestValidation)-> Promise<[String: Any]> {
        
        /// Validate local contact
        return localContact(params.localContact).recover { error-> Promise<[String: Any]> in
            
            /// Local contact failed, validate free form
            return freeFormContact(params.freeFormContact)
        }
    }
    
    // MARK: - Utilities
    /// Relation validation
    class func relation(_ string: String)-> Promise<String> {
        return Promise { fulfill, reject in
            
            if string.length > 0 {
                fulfill(string)
                return
            }
            
            reject(NewRequestValidationError.relation)
        }
    }
    
    /// Age validation
    class func age(_ string: String)-> Promise<String> {
        return Promise { fulfill, reject in
            
            if string.length > 0 {
                fulfill(string)
                return
            }
            
            reject(NewRequestValidationError.age)
        }
    }
    
    class func gender(_ string: String) -> Promise<String> {
        return Promise { fulfill, reject in
            
            if string.length > 0 {
                fulfill(string)
                return
            }
            
            reject(NewRequestValidationError.gender)
        }
    }
    
    /// Token contact validation
    class func tokenContact(_ contact: TMContact?)-> Promise<TMContact> {
        return Promise { fulfill, reject in
            
            guard let contact = contact else {
                reject(NewRequestValidationError.contact)
                return
            }
            
            fulfill(contact)
        }
    }
    
    /// Local contact validation
    /// Returns dictionary for net request
    class func localContact(_ contact: CNContact?)-> Promise<[String: Any]> {
        return Promise { fulfill, reject in
            
            guard let contact = contact else {
                reject(NewRequestValidationError.contact)
                return
            }
            
            fulfill(contact.transferToJSON())
        }
    }
    
    /// Free form contact validation
    /// Returns dictionary for net request
    class func freeFormContact(_ string: String?)-> Promise<[String: Any]> {
        return Promise { fulfill, reject in
            
            guard let string = string, string.length > 0 else {
                reject(NewRequestValidationError.contact)
                return
            }
            
            /// Format text
            let components = string.components(separatedBy: " ")
            let fName = components.first ?? ""
            let lName = components.filter{$0 != fName}.map{$0}.joined() 
            
            /// Result
            var result: [String: Any] = [:]
            
            /// Current user id
            let config = TMConsumerConfig.shared
            result[NewRequestValidationJSON.userID] = config.currentUser!.id
            
            /// First/Last name - contact
            result[TMContactJSON.firstName] = fName
            result[TMContactJSON.lastName] = lName
            
            fulfill(result)
        }
    }
    
    /// Location validation
    class func location(_ string: String?)-> Promise<String> {
        return Promise { fulfill, reject in
            
            guard let string = string, string.length > 0 else {
                reject(NewRequestValidationError.location)
                return
            }
            
            fulfill(string)
        }
    }
    
    /// Occasion validation
    /// Returns occasion name and attributeID
    /// So that we can recover in promise
    class func occasion(_ occasion: TMRequestAttribute?)-> Promise<(occasionName: String, attributeID: String)> {
        return Promise { fulfill, reject in
            
            guard let occasion = occasion, let occasionName = occasion.name, occasionName.length > 0 else {
                reject(NewRequestValidationError.occasion)
                return
            }
            
            fulfill((occasionName: occasionName, attributeID: occasion.id))
        }
    }
    
    /// Occasion free form validation
    /// Returns occasion name and attributeID
    /// So that we can recover in promise
    class func occasionFreeForm(_ string: String?)-> Promise<(occasionName: String, attributeID: String)> {
        return Promise { fulfill, reject in
            
            guard let string = string, string.length > 0 else {
                reject(NewRequestValidationError.occasion)
                return
            }
            
            fulfill((occasionName: string, attributeID: ""))
        }
    }
    
    /// Styles validation
    class func styles(_ styles: [String]?)-> Promise<[String]> {
        
        return Promise { fulfill, reject in
            
            guard let styles = styles, styles.count > 0 else {
                reject(NewRequestValidationError.style)
                return
            }
            
            fulfill(styles)
        }
    }
    
    /// Interests validation
    class func interests(_ interests: [String]?)-> Promise<[String]> {
        
        return Promise { fulfill, reject in
            
            guard let interests = interests, interests.count > 0 else {
                reject(NewRequestValidationError.interests)
                return
            }
            
            fulfill(interests)
        }
    }
    
    /// Details validation
    class func details(_ string: String?)-> Bool {
        return true
    }
}
