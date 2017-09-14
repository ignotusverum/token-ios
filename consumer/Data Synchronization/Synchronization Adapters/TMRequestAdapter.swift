//
//  TMRequestAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/1/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import PromiseKit
import SwiftyJSON
import JDStatusBarNotification

class TMRequestAdapter: TMSynchronizerAdapter {

    static var totalCount = 0
    
    /// Adapter synchronized
    override func synchronizeData() {
        
        TMRequestAdapter.fetchRequestList().then { response-> Void in
            
            super.synchronizeData()
            }.catch { error-> Void in
                
                super.synchronizeData()
        }
    }
    
    // MARK: - Networking calls
    /// Fetching request details
    ///
    /// - Parameters:
    ///   - requestID: request id
    ///   - context: context for database
    /// - Returns: request object
    class func fetch(requestID: String)-> Promise<TMRequest?> {
        
        TMRequestAdapter.getTotalCount().catch { error in
            print(error)
        }
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "requests/\(requestID)").then { responseJSON-> Promise<TMRequest?> in
            
            return TMCoreDataManager.insertASync(Into<TMRequest>(), source: responseJSON)
            }.then { request-> Promise<TMRequest?> in
                
                return TMCoreDataManager.fetchExisting(request)
        }
    }
    
    /// Creates new request
    ///
    /// - Parameter params: request info
    /// - Returns: created request
    class func createRequest(_ params: [String: Any]?)-> Promise<TMRequest?> {
        
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "requests", parameters: params).then { responseJSON-> Promise<TMRequest?> in
            
            return TMCoreDataManager.insertASync(Into<TMRequest>(), source: responseJSON)
            
            }.then { request-> Promise<TMRequest?> in
                
                return TMCoreDataManager.fetchExisting(request)
            }
    }
    
    /// Remove old requests from database
    ///
    /// - Parameter requests: requests from server
    class func removeOldRequests(_ requests: [JSON]) {
        
        let requestsIDs = requests.flatMap { $0["id"].string }
        
        TMCoreDataManager.defaultStack.beginAsynchronous { transaction-> Void in
            
            transaction.deleteAll(From<TMRequest>(), Where("NOT (%K IN %@)", TMModelAttributes.id.rawValue, requestsIDs))
            transaction.commit()
        }
    }
    
    /// Get total count of requests
    ///
    /// - Returns: count of requests
    class func getTotalCount()-> Promise<Int?> {
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "requests?limit=\(0)&offset=\(0)").then { responseJSON -> Int in
            
            // Get total count from response
            if let count = responseJSON["total_count"].int {
                
                TMRequestAdapter.totalCount = count
                
                return count
            }
            
            return 0
        }
    }
    
    /// Fetch request list with number
    ///
    /// - Parameter limit: number of items to fetch
    /// - Returns: array of requests
    class func fetchRequestList(limit: Int = 15)-> Promise<[TMRequest]> {
        
            let netman = TMNetworkingManager.shared
            
            (limit)&offset=\(0)").then { response -> Promise<[TMRequest]> in
                
                // Getting total count
                if let count = response["total_count"].int {

                    TMRequestAdapter.totalCount = count
                    
                    // Deleting old requests
                    if count == 0 {
                        
                        self.removeOldRequests([])
                        return Promise(value: [])
                    }
                }
                
                guard let responseArray = response["data"].array else {
                    return Promise(value: [])
                }
                
                // Deleting old requests
                self.removeOldRequests(responseArray)
                
                return TMCoreDataManager.insertASync(Into<TMRequest>(), source: responseArray)
                }.then { response-> Promise<[TMRequest]> in
                    
                    return TMCoreDataManager.fetchExisting(response)
                }
//                .then { response-> Promise<[TMRequest]> in
//                    
//                    return Promise { fulfill, reject in
//                     
//                        for request in response {
//                         
//                            TMRecommendationsAdapter.fetchRecommendations(request: request).catch { error in
//                                print(error)
//                            }
//                        }
//                        
//                        fulfill(response)
//                    }
//        }
    }
}
