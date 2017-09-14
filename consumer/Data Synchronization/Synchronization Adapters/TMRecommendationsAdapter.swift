
//  TMRecommendationsAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/26/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON
import PromiseKit

class TMRecommendationsAdapter: TMSynchronizerAdapter {

    /// Sets recommendation as seen
    ///
    /// - Parameter recommendation: recommendation for updates
    /// - Returns: success/failure
    class func setSeen(recommendation: TMRecommendation)-> Promise<Bool> {
    
        let requestID = recommendation.request!.id
    
        guard let recomSeen = recommendation.seen,
            recomSeen.boolValue == false else {
                
            return Promise(value: true)
        }
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "requests/\(requestID!)/recommendations/\(recommendation.id!)/seen", parameters: nil).then { response-> Promise<TMRecommendation?> in
            
            return TMCoreDataManager.insertASync(Into<TMRecommendation>(), source: response)
            }.then { response-> Promise<TMRecommendation?> in
        
                return TMCoreDataManager.fetchExisting(recommendation)
            }.then { recommendation-> Promise<Bool> in
        
                return Promise { fulfill, reject in
                    
                    TMCoreDataManager.defaultStack.beginAsynchronous { transaction in
                        
                        let recommendation = transaction.edit(recommendation)
                        
                        // Save
                        recommendation?.seen = NSNumber(value: true)
                        
                        recommendation?.request?.seen = NSNumber(value: true)
                        
                        _ = transaction.commit()
                        
                        fulfill(true)
                    }
                }
        }
    }
    
    /// Rate recommendation request
    ///
    /// - Parameters:
    ///   - recommendation: recommendation for updates
    ///   - feedback: feedback string
    /// - Returns: success/failure
    class func rate(recommendation: TMRecommendation, feedback: String)-> Promise<Bool> {
        
        let recommendationID = recommendation.id
        let requestID = recommendation.request!.id
        
        // Prarms for request
        let params: [String: Any]? = ["feedback": feedback]
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.patch, path: "requests/\(requestID!)/recommendations/\(recommendationID!)", parameters: params).then { response-> Promise<TMRequest?> in
            
            return TMRequestAdapter.fetch(requestID: requestID!)
            }.then { request-> Bool in
                
                return true
        }
    }
    
    /// Fetch recommendations for request - saving only published recommendations
    ///
    /// - Parameter request: request for recommendations
    /// - Returns: array of recommendations
    class func fetchRecommendations(request: TMRequest)-> Promise<[TMRecommendation]> {
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "requests/\(request.id!)/recommendations").then { response-> Promise<[TMRecommendation]> in
            
            guard let jsonArray = response.array else {
                return Promise(value: [])
            }
            
            let publishedRecommendations = jsonArray.filter { $0["published"].bool == true }
            
            return TMCoreDataManager.insertASync(Into<TMRecommendation>(), source: publishedRecommendations)
            }.then { recommendations-> Promise<[TMRecommendation]> in
             
                return TMCoreDataManager.fetchExisting(recommendations)
            }.then { recommendations-> Promise<[TMRecommendation]> in
                
                return Promise { fulfill, reject in
                    
                    TMCoreDataManager.defaultStack.beginAsynchronous { transaction in
                        
                        let request = transaction.edit(request)
                        let recommendations = recommendations.flatMap { transaction.edit($0) }
                        
                        request?.addRecommendations(NSOrderedSet(array: recommendations))
                        
                        _ = transaction.commit()
                        
                        fulfill(recommendations)
                    }
                }
        }
    }
}
