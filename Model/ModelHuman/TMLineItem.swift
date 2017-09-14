//
//  TMLineItem.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON

/// Struct that represent Line Item JSON keys
public struct TMLineItemJSON {
    
    static let currency = "currency"
    static let ownerID = "ownerID"
    static let ownerType = "ownerType"
    static let price = "price"
    static let productID = "productID"
    static let quantity = "quantity"
    static let shippingRequired = "shippingRequired"
    static let sku = "sku"
    static let taxable = "taxable"
    static let title = "title"
    static let variantID = "variantID"
}

@objc(TMLineItem)
open class TMLineItem: _TMLineItem {

    public override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        try super.updateModel(with: source, transaction: transaction)
        
        // Currency
        self.currency = source[TMLineItemJSON.currency].string
        
        // Owner ID
        self.ownerID = source[TMLineItemJSON.ownerID].string
        
        // Owner Type
        self.ownerType = source[TMLineItemJSON.ownerType].string
        
        // Price 
        self.price = source[TMLineItemJSON.price].number
        
        // Product ID
        self.productID = source[TMLineItemJSON.productID].string
        
        // Quantity
        self.quantity = source[TMLineItemJSON.quantity].number
        
        // Shipping required
        self.shippingRequired = source[TMLineItemJSON.shippingRequired].number
        
        // SKU
        self.sku = source[TMLineItemJSON.sku].string
        
        // Taxable
        self.taxable = source[TMLineItemJSON.taxable].number
        
        // Title
        self.title = source[TMLineItemJSON.title].string
        
        // Variant ID
        self.variantID = source[TMLineItemJSON.variantID].string
    }
}
