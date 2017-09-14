//
//  TMCartItem.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON

/// Struct that represent Cart Item JSON keys
public struct TMCartItemJSON {
    
    static let productID = "product_id"
    static let currency = "currency"
    static let quantity = "quantity"
    static let variantID = "variant_id"
    static let cartID = "cart_id"
}

@objc(TMCartItem)
open class TMCartItem: _TMCartItem {
    
    func transformForCartJSONWithQuantity(_ quantity: Int)-> [String: Any] {
        
        var resultDictionary = [String: Any]()
        
        if let cartID = self.cartID {
            
            resultDictionary["cart_id"] = cartID
        }
        
        if let productID = self.product?.id {
            
            resultDictionary["product_id"] = productID
        }
        
        resultDictionary["quantity"] = quantity
        
        if let price = self.product?.price {
            
            resultDictionary["price"] = price
        }
        
        if let currency = self.product?.currency {
            
            resultDictionary["currency"] = currency
        }
        
        return resultDictionary
    }
    
    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        try super.updateModel(with: source, transaction: transaction)
        
        // Product ID
        self.productID = source[TMCartItemJSON.productID].string ?? ""
        
        // Product relation
        if self.product == nil {
            self.product = transaction.fetchOne(From<TMProduct>(),
                                                Where("\(TMModelAttributes.id.rawValue) == %@", productID))
        }
        
        // Currency
        self.currency = source[TMCartItemJSON.currency].string
        
        // Quantity
        self.quantity = source[TMCartItemJSON.quantity].number
        
        // Variant ID
        self.variantID = source[TMCartItemJSON.variantID].string
        
        // Cart ID
        self.cartID = source[TMCartItemJSON.cartID].string
    }
}
