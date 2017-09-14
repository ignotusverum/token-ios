//
//  AddressField.swift
//  consumer
//
//  Created by Gregory Sapienza on 1/19/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

/// All address fields represented as cells in table view.
///
/// - fullName: Name
/// - addressLine1: Address Line 1
/// - addressLine2: Address Line 2
/// - city: City
/// - state: State
/// - zipCode: Zip Code
/// - placeName: Place name for address. Referred to as 'line' in address object property.
enum AddressField: String {
    case fullName = "Full Name"
    case addressLine1 = "Address Line 1"
    case addressLine2 = "Address Line 2 (Optional)"
    case city = "City"
    case state = "State"
    case zipCode = " Zip Code"
    case placeName = "This Location's Name"
    
    /// Placeholder text for each address field.
    ///
    /// - Returns: String of placeholder text for a specified address field.
    func placeholderText() -> String {
        switch self {
        case .fullName:
            return "Vince Staples"
        case .addressLine1:
            return "123 Maple Lane"
        case .addressLine2:
            return "Apartment #"
        case .city:
            return "City"
        case .state:
            return "State"
        case .zipCode:
            return "12345"
        case .placeName:
            return "Home"
        }
    }
    
    func fieldType() -> AddressFieldType {
        switch self {
        case .fullName:
            return .textField
        case .addressLine1:
            return .textField
        case .addressLine2:
            return .textField
        case .city:
            return .textField
        case .state:
            return .picker(items: AddressField.stateCodes, textEntryAllowed: false)
        case .zipCode:
            return .textField
        case .placeName:
            return .picker(items: ["Home", "Work"], textEntryAllowed: true)
        }
    }
    
    /// Translates a property in an address object based on enum value.
    ///
    /// - Parameter address: Address to retrieve property value.
    /// - Returns: String containing propery value.
    func contactAddressProperty(address :TMContactAddress) -> String? {
        switch self {
        case .fullName:
            return address.name
        case .addressLine1:
            return address.street
        case .addressLine2:
            return address.street2
        case .city:
            return address.city
        case .state:
            return address.state
        case .zipCode:
            return address.zip
        case .placeName:
            return address.label
        }
    }
    
    /// Minimum allowed characters for a particular field.
    ///
    /// - Returns: Integer containing minimum amount of characters.
    func minimumCharacterCount() -> Int {
        switch self {
        case .fullName:
            return 0
        case .addressLine1:
            return 2
        case .addressLine2:
            return 0
        case .city:
            return 0
        case .state:
            return 0
        case .zipCode:
            return 2
        case .placeName:
            return 0
        }
    }
    
    /// Validation error per enum value.
    ///
    /// - Returns: Error for validating enum text field.
    func validationError() -> NSError {
        let errorDomain = "ai.token.consumerApp"
        
        switch self {
        case .fullName:
            return NSError(domain: errorDomain, code: 1000, userInfo: nil)
        case .addressLine1:
            return NSError(domain: errorDomain, code: 1001, userInfo: nil)
        case .addressLine2:
            return NSError(domain: errorDomain, code: 1002, userInfo: nil)
        case .city:
            return NSError(domain: errorDomain, code: 1003, userInfo: nil)
        case .state:
            return NSError(domain: errorDomain, code: 1004, userInfo: nil)
        case .zipCode:
            return NSError(domain: errorDomain, code: 1005, userInfo: nil)
        case .placeName:
            return NSError(domain: errorDomain, code: 1006, userInfo: nil)
        }
    }
    
    /// Error message per error code.
    ///
    /// - Parameter errorCode: Error code.
    /// - Returns: String containing message based on error code.
    static func errorMessage(errorCode :Int) -> String? {
        switch errorCode {
        case 1000:
            return "Invalid Name"
        case 1001:
            return "Invalid Address Line 1"
        case 1002:
            return "Invalid Address Line 2"
        case 1003:
            return "Invalid City"
        case 1004:
            return "Invalid State"
        case 1005:
            return "Invalid Zip Code"
        case 1006:
            return "Invalid Place"
        default:
            return nil
        }
    }
    
    /// Default text for each address field.
    ///
    /// - Returns: String value for default text for address field.
        func defaultText() -> String? {
        switch self {
        case .placeName:
                return "Home"
        default:
                return nil
        }
    }
    
    /// All address fields as enum values.
    ///
    /// - Returns: Array of address field enum values.
    static func addressFields() -> [AddressField] {
        return [.fullName, .addressLine1, .addressLine2, .city, .state, .zipCode, .placeName]
    }
    
    /// Sorted shortened state codes from plist file.
    private static var stateCodes: [String] {
        guard let path = Bundle.main.path(forResource: "stateCodeMap", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: String] else {
            
            return []
        }
        
        return dict.map({ (long: String, short: String) -> String in
            return short
        }).sorted{ $0 < $1 }
    }
}

/// Address field type for textfield.
///
/// - textField: Normal text field.
/// - picker: Picker input.
enum AddressFieldType {
    case textField
    case picker(items: [String], textEntryAllowed: Bool)
}
