//
//  TMShippingAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/31/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import PromiseKit

class TMShippingAdapter: TMSynchronizerAdapter {

    /// Fetch shipping types
    ///
    /// - Returns: array of shipping types
    class func fetch()-> Promise<[TMShippingType]> {
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "shipping/types").then { result-> Promise<[TMShippingType]> in
            
            guard let jsonArray = result.array else {
                return Promise(value: [])
            }
            
            return TMCoreDataManager.insertASync(Into<TMShippingType>(), source: jsonArray)
            }.then { result-> Promise<[TMShippingType]> in
            
                return TMCoreDataManager.fetchExisting(result)
        }
    }
}
