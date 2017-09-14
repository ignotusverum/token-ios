//
//  TMTaxLine.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON

/// Struct that represent Recommendation JSON keys
public struct TMTaxLineJSON {
    
    static let currency = "currency"
    static let ownerID = "ownerID"
    static let ownerType = "ownerType"
    static let price = "price"
    static let rate = "rate"
    static let title = "title"
}

@objc(TMTaxLine)
open class TMTaxLine: _TMTaxLine {

    public override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        try super.updateModel(with: source, transaction: transaction)
        
        // Currency
        self.currency = source[TMTaxLineJSON.currency].string
        
        // Owner ID
        self.ownerID = source[TMTaxLineJSON.ownerID].string
        
        // Owner Type
        self.ownerType = source[TMTaxLineJSON.ownerID].string
        
        // Price
        self.price = source[TMTaxLineJSON.price].number
        
        // Rate
        self.rate = source[TMTaxLineJSON.rate].number
        
        // Title
        self.title = source[TMTaxLineJSON.title].string
    }
}
