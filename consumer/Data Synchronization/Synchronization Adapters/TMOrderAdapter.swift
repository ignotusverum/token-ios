//
//  TMOrderAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/26/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import PromiseKit
import SwiftyJSON

class TMOrderAdapter: TMSynchronizerAdapter {

    /// Fetch order details for order id
    ///
    /// - Parameter orderID: order id
    /// - Returns: return order object
    class func fetch(orderID: String)-> Promise<TMOrder?> {
        
        let netman = TMNetworkingManager.shared
        
        return netman.request(.get, path: "orders/\(orderID)").then { response-> Promise<TMOrder?> in
            
            guard let resultJSON = response["result"].dictionary else {
                return Promise(value: nil)
            }
            
            let source = JSON(resultJSON)
            
            return TMCoreDataManager.insertASync(Into<TMOrder>(), source: source)
            }.then { response-> Promise<TMOrder?> in
                
                return TMCoreDataManager.fetchExisting(response)
        }
    }
}
