//
//  TMCommerceAnalytics.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/15/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

import Analytics

import SwiftyJSON

enum EcommerceEvent: String {
    
    case Viewed = "Viewed Product"
    case Added = "Added Product"
    case Removed = "Removed Product"
    case Completed = "Completed Order"
}

class TMCommerceAnalytics: NSObject {

    // Singleton
    static let sharedManager = TMCommerceAnalytics()
    
    // Product Viewed
    class func trackViewedForProduct(_ product: TMProduct?) {
        
        guard let product = product else {
            
            return
        }
        
        let productDict = product.getAnalyticsDict()
        
        SEGAnalytics.shared().track(EcommerceEvent.Viewed.rawValue, properties: productDict)
    }
    
    // Product Added
    class func trackAddedForProduct(_ product: TMProduct?) {
        
        guard let product = product else {
            
            return
        }
        
        let productDict = product.getAnalyticsDict()
        
        SEGAnalytics.shared().track(EcommerceEvent.Added.rawValue, properties: productDict)
    }
    
    // Product Removed
    class func trackRemovedForProduct(_ product: TMProduct?) {
        
        guard let product = product else {
            
            return
        }
        
        let productDict = product.getAnalyticsDict()
        
        SEGAnalytics.shared().track(EcommerceEvent.Removed.rawValue, properties: productDict)
    }
    
    // Order Finished
    class func trackFinishedForOrder(_ order: TMOrder?, productArray: [[String: Any]]) {
        
        guard let order = order else {
            
            return
        }
        
        var orderDict = order.getAnalyticsDict()
        orderDict["products"] = productArray
        
        SEGAnalytics.shared().track(EcommerceEvent.Completed.rawValue, properties: orderDict)
    }
}
