//
//  TMNewRequestAnalytics.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/20/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

class TMNewRequestAnalytics {
    
    /// Track new request actions
    class func trackNewRequest(request: TMRequest?) {
        
        guard let request = request else {
            return
        }
    
        var requestAnalytics = [String: Any]()
        
        if let requestID = request.id {
            requestAnalytics["requestID"] = requestID
        }
        
        if let contactID = request.contactID {
            requestAnalytics["contacatID"] = contactID
        }
        
        if let occasion = request.occasion {
            requestAnalytics["occasion"] = occasion
        }
        
        if let age = request.age {
            requestAnalytics["age"] = age
        }
        
        if let location = request.location {
            requestAnalytics["location"] = location
        }
        
        if let relationship = request.relation {
            requestAnalytics["relationship"] = relationship
        }
        
        if let priceLow = request.priceLow {
            requestAnalytics["priceLow"] = priceLow
        }
        
        if let priceHigh = request.priceHigh {
            requestAnalytics["priceHigh"] = priceHigh
        }
        
        if let createdAt = request.createdAt {
            requestAnalytics["createdAt"] = createdAt
        }
        
        TMAnalytics.trackEventWithID(.t_S5_4, eventParams: requestAnalytics)
    }
}
