//
//  TMShippingType.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import SwiftyJSON
import CoreStore

/// Struct that represent Order JSON keys
public struct TMShippingTypeJSON {
    
    static let active = "active"
    static let displayPrice = "display_price"
    static let image = "image"
    static let order = "order"
    static let title = "title"
    static let description = "description"
}

/// Wrapping type text
enum WrappingType: String {
    
    case wrapped = "Gift Wrapped with Card"
    case unwrapped = "Unwrapped"
}

@objc(TMShippingType)
open class TMShippingType: _TMShippingType {

    var wrappingType: WrappingType {
        
        // Setting wrappingType enum
        if title?.uppercased() == "UNWRAPPED" {
            
            return .unwrapped
        }
        
        return  .wrapped
    }
    
    public override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        try super.updateModel(with: source, transaction: transaction)
        
        // Active
        active = source[TMShippingTypeJSON.active].number
        
        // Display Price
        displayPrice = source[TMShippingTypeJSON.displayPrice].string
        
        // Image
        imageString = source[TMShippingTypeJSON.image].string
        
        // Order
        order = source[TMShippingTypeJSON.order].number
        
        // Title
        title = source[TMShippingTypeJSON.title].string
        
        // Description
        typeDescription = source[TMShippingTypeJSON.description].string
    }
}
