//
//  TMCart.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON
import PromiseKit

/// Struct that represent Cart Label JSON keys
public struct TMCartJSON {
    
    static let destination = "destination"
    
    static let total = "total"
    static let subtotal = "subtotal"
    static let totalFee = "total_fee"
    static let totalTax = "total_tax"
    static let totalShipping = "total_shipping"
    
    static let orderID = "order_id"
    static let wrappingID = "wrapping_id"
    
    static let shippingMethod = "shipping_type_id"
    
    static let items = "items"
    
    static let label = "label"
}

// Fee Structure
struct TMFee {
    
    // Defined fee types
    public enum FeeType: String {
        
        case shipping = "Shipping"
        case service = "Service Fee"
        case tax = "Tax"
        case subtotal = "Sub-Total"
        case none = ""
    }
    
    var feeType: FeeType
    
    var value: Float
}

@objc(TMCart)
open class TMCart: _TMCart {
    
    var subTotalFee: TMFee? {
        
        guard let subtotal = subtotal else {
            return nil
        }
        
        return TMFee(feeType: .subtotal, value: subtotal.floatValue)
    }
    
    // Cart Fees
    var fees: [TMFee] {
        
        // Result array
        var result: [TMFee] = []
        
        // Subtotal check
        if let serviceFee = self.totalFee?.floatValue, serviceFee > 0 {
            
            result.append(TMFee(feeType: .service, value: serviceFee))
        }
        
        // Shipping check
        if let shippingFee = self.totalShipping?.floatValue, shippingFee > 0 {
            
            result.append(TMFee(feeType: .shipping, value: shippingFee))
        }
        
        // Tax check
        if let taxFee = self.totalTax?.floatValue, taxFee > 0 {
            
            result.append(TMFee(feeType: .tax, value: taxFee))
        }
        
        return result
    }
    
    // Items array
    var itemsArray: [TMCartItem] {
        
        return items.array as? [TMCartItem] ?? []
    }
    
    var serviceFeePercentage: Int {
        
        let subtotalValue = subtotal?.floatValue ?? 0
        let totalFeeValue = totalFee?.floatValue ?? 1
        
        return Int(((totalFeeValue / subtotalValue) * Float(100)).rounded())
    }

    // Check if there's something in cart
    var cartIsEmpty: Bool {
        
        if itemsArray.count > 0 {
            
            return false
        }
        
        return true
    }
    
    // Checkout status
    var isCheckoutAvaliable: Bool {
        
        guard let request = request else {
            return false
        }
        
        if request.status != .selection && request.status != .pending {
            return false
        }
        
        return true
    }
    
    // Check if item with product id in a cart
    func isProductInCart(_ productID: String)-> Bool {
        
        let itemPredicate = Where("\(TMCartItemAttributes.productID.rawValue) == %@", productID)
        let cartPredicate = Where("\(TMCartItemAttributes.cartID.rawValue) == %@", id)
        
        let result = TMCoreDataManager.defaultStack.fetchCount(From<TMCartItem>(), itemPredicate && cartPredicate)
        
        return (result ?? 0) > 0
    }
    
    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        try super.updateModel(with: source, transaction: transaction)

        // Destination
        destination = source[TMCartJSON.destination].string
        
        // Subtotal
        subtotal = source[TMCartJSON.subtotal].price
        
        // Order ID
        orderID = source[TMCartJSON.orderID].string
        
        // Shipping method
        shippingMethod = source[TMCartJSON.shippingMethod].string
        
        // Wrapping ID
        wrappingID = source[TMCartJSON.wrappingID].string
        
        // Total Shipping
        totalShipping = source[TMCartJSON.totalShipping].price
        
        // Total Fee
        totalFee = source[TMCartJSON.totalFee].price
        
        // Total Tax
        totalTax = source[TMCartJSON.totalTax].price
        
        // Total
        total = source[TMCartJSON.total].price
        
        // Fetch Items
        let itemsJSONArray = source[TMCartJSON.items].array ?? []
        let tempItems = try transaction.importUniqueObjects(Into<TMCartItem>(), sourceArray: itemsJSONArray)
        addItems(NSOrderedSet(array: tempItems))
        
        // Label
        let labelJSON = source[TMCartJSON.label].json
        if let labelJSON = labelJSON {
            self.label = try transaction.importUniqueObject(Into<TMCartLabel>(), source: labelJSON)
        }
    }
}
