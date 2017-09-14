//
//  TMOrder.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import PromiseKit
import SwiftyJSON

/// Struct that represent Order JSON keys
public struct TMOrderJSON {
    
    static let currency = "currency"
    static let status = "status"
    static let subTotal = "sub_total"
    static let total = "total"
    static let totalShipping = "total_shipping"
    static let totalTax = "total_tax"
    static let userID = "userID"
    static let paymentStatus = "payment_status"
    static let requestID = "request_id"
    static let label = "label"
}

@objc(TMOrder)
open class TMOrder: _TMOrder {

    public override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        try super.updateModel(with: source, transaction: transaction)
        
        // Currency
        self.currency = source[TMOrderJSON.currency].string
        
        // Status
        self.status = source[TMOrderJSON.status].string
        
        // Subtotal
        self.subTotal = source[TMOrderJSON.subTotal].number
        
        // Total Price
        self.totalPrice = source[TMOrderJSON.total].number
        
        // Total Shipping
        self.totalShipping = source[TMOrderJSON.totalShipping].number
        
        // Total Tax
        self.totalTax = source[TMOrderJSON.totalTax].number
        
        // User ID
        self.userID = source[TMOrderJSON.userID].string
        
        // Payment Status
        self.paymentStatus = source[TMOrderJSON.paymentStatus].string
        
        // Request ID
        self.requestID = source[TMOrderJSON.requestID].string
    }

    func getAnalyticsDict()-> [String: Any] {
        
        var result = [String: Any]()
        
        if let orderID = self.id {
            
            result["orderId"] = orderID
        }
        
        if let total = self.totalPrice {
            
            result["total"] = total.intValue / 100
        }
        
        if let revenue = self.subTotal {
            
            result["revenue"] = revenue.intValue / 100
        }
        
        if let shipping = self.totalShipping {
            
            result["shipping"] = shipping.intValue / 100
        }
        
        if let tax = self.totalTax {
            
            result["tax"] = tax.intValue / 100
        }
        
        // NO discount
        
        // NO Coupon logic implemented
        
        result["currency"] = "USD"
        
        return result
    }
}
