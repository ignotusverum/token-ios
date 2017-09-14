//
//  TMCartAddress.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON

/// Struct that represent Cart Address JSON keys
public struct TMCartAddressJSON {
    
    static let cartID = "cart_id"
    static let city = "city"
    static let company = "company"
    static let label = "label"
    static let name = "name"
    static let sourceID = "source_id"
    static let street1 = "street1"
    static let street2 = "street2"
    static let verified = "verified"
    static let zip = "zip"
}

@objc(TMCartAddress)
public class TMCartAddress: _TMCartAddress {

    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        try super.updateModel(with: source, transaction: transaction)
        
        // Cart ID
        self.cartID = source[TMCartAddressJSON.cartID].string
        
        // City
        self.city = source[TMCartAddressJSON.city].string
        
        // Company
        self.company = source[TMCartAddressJSON.company].string
        
        // Label
        self.label = source[TMCartAddressJSON.label].string
        
        // Name
        self.name = source[TMCartAddressJSON.name].string
        
        // Source ID
        self.sourceID =  source[TMCartAddressJSON.sourceID].string
        
        // Street 1
        self.street1 = source[TMCartAddressJSON.street1].string
        
        // Street 2
        self.street2 = source[TMCartAddressJSON.street2].string
        
        // Verified
        self.verified = source[TMCartAddressJSON.verified].number
        
        // Zip
        self.zip = source[TMCartAddressJSON.zip].string
    }
}
