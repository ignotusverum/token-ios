//
//  TMContactAddress.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import PromiseKit
import SwiftyJSON

/// Struct that represent Payment JSON keys
public struct TMContactAddressJSON {
    
    static let id = "id"
    static let userID = "user_id"
    static let city = "city"
    static let company = "company"
    
    static let state = "state"
    static let country = "country"
    
    static let label = "label"
    static let name = "name"
    
    static let street1 = "street1"
    static let street2 = "street2"
    
    static let zip = "zip"
}

@objc(TMContactAddress)
open class TMContactAddress: _TMContactAddress {

    // Json model
    class func requestParams(fullName: String, addressLine: String, addressLine2: String?, city: String, state: String, zip: String, label: String?)-> [String: Any]? {
        
        var dictForRequest = [String: Any]()
        dictForRequest["name"] = fullName
        dictForRequest["label"] = label
        dictForRequest["street1"] = addressLine
        dictForRequest["street2"] = addressLine2
        dictForRequest["city"] = city
        dictForRequest["state"] = state
        dictForRequest["zip"] = zip
        
        return dictForRequest
    }
    
    func getDictFromObject()-> [String: Any] {
        
        var dictForRequest = [String: Any]()
        
        if let name = self.name {
            dictForRequest["name"] = name as Any?
        }
        
        if let label = self.label {
            dictForRequest["label"] = label as Any?
        }
        
        if let addressLine = self.street {
            dictForRequest["street1"] = addressLine as Any?
        }
        
        if let addressLine2 = self.street2 {
            dictForRequest["street2"] = addressLine2 as Any?
        }
        
        if let city = self.city {
            dictForRequest["city"] = city as Any?
        }
        
        if let state = self.state {
            dictForRequest["state"] = state as Any?
        }
        
        if let zip = self.zip {
            dictForRequest["zip"] = zip as Any?
        }
        
        return dictForRequest
    }
    
    // Utilities
    class func getAddressDetailsStringFromAddress(_ address: TMContactAddress?)-> String {
        
        // Safety check
        guard let _address = address else {
            return ""        }
        
        // Address label
        var addressString = ""
        
        if let _street = _address.street {
            addressString = addressString + _street + "\n"
        }
        
        if let _city = _address.city {
            addressString = addressString + _city + "," + " "
        }
        
        if let _state = _address.state {
            addressString = addressString + _state + " "
        }
        
        if let _zip = _address.zip {
            addressString = addressString + _zip
        }
        
        return addressString
    }
    
    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        try super.updateModel(with: source, transaction: transaction)
  
        // City
        self.city = source[TMContactAddressJSON.city].string
        
        // User ID
        self.userID = source[TMContactAddressJSON.userID].string
        
        // Company
        self.company = source[TMContactAddressJSON.company].string
        
        // State
        self.state = source[TMContactAddressJSON.state].string
        
        // Country
        self.country = source[TMContactAddressJSON.country].string

        // Label
        self.label = source[TMContactAddressJSON.label].string
        
        // Name
        self.name = source[TMContactAddressJSON.name].string
        
        // Street 1
        self.street = source[TMContactAddressJSON.street1].string
        
        // Street 2
        self.street2 = source[TMContactAddressJSON.street2].string
        
        // Zip
        self.zip = source[TMContactAddressJSON.zip].string
    }
}
