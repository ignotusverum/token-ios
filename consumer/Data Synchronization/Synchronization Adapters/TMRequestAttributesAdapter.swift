//
//  TMRequestAttributesAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/19/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import PromiseKit
import SwiftyJSON

class TMRequestAttributesAdapter: TMSynchronizerAdapter {

    /// Adapter synchronized
    override func synchronizeData() {
        
        // Fetching attribute
        TMRequestAttributesAdapter.fetchAttributes().then { result-> Void in
            
            super.synchronizeData()
            }.catch { error-> Void in
                
                super.synchronizeData()
        }
    }
    
    // MARK: - Networking calls
    
    /// Fetching attributes from server
    ///
    /// - Returns: array of attribute objects
    class func fetchAttributes()-> Promise<[TMRequestAttribute]> {
    
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "attributes").then { responseJSON-> Promise<[TMRequestAttribute]> in
            
            guard let resultJSONArray = responseJSON.dictionary?["results"]?.array else {
                return Promise(value: [])
            }
         
            // Remove old attributes
            removeOldAttributes(resultJSONArray)
            
            return TMCoreDataManager.insertASync(Into<TMRequestAttribute>(), source: resultJSONArray)
        }
    }
    
    /// Remove old request attributes from database
    ///
    /// - Parameter requests: requests attributes from server
    class func removeOldAttributes(_ requests: [JSON]) {
        
        let requestsIDs = requests.flatMap { $0["id"].string }
        
        TMCoreDataManager.defaultStack.beginAsynchronous { transaction-> Void in
            
            transaction.deleteAll(From<TMRequestAttribute>(), Where("NOT (%K IN %@)", TMModelAttributes.id.rawValue, requestsIDs))
            transaction.commit()
        }
    }
}
