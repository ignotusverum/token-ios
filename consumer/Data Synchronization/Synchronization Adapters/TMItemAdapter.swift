//
//  TMItemAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/30/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON
import PromiseKit

class TMItemAdapter: TMSynchronizerAdapter {

    /// Rate item in recommendation set
    class func rate(item: TMItem?, feedbackType: TMFeedbackType)-> Promise<TMItem?> {
        
        guard let item = item, let recommendation = item.recommendation, let request = recommendation.request else {
            return Promise(value: nil)
        }
        
        /// URL for patch
        let rateURLString = "requests/\(request.id!)/recommendations/\(recommendation.id!)/items/\(item.id!)"
        
        /// Rate parameters
        let rateParams = ["rating": feedbackType.rawValue]
        
        /// Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.patch, path: rateURLString, parameters: rateParams).then { response-> Promise<TMItem?> in
            
            return TMCoreDataManager.insertASync(Into<TMItem>(), source: response).then { savedObject-> Promise<TMItem?> in
                
                return TMCoreDataManager.fetchExisting(savedObject)
            }
        }
    }
}
