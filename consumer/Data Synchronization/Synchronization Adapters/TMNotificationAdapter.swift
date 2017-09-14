//
//  TMNotificationAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/24/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON
import PromiseKit

class TMNotificationAdapter: TMSynchronizerAdapter {

    /// Adapter synchronized
    override func synchronizeData() {
        TMNotificationAdapter.fetch().then { response-> Void in
            
            super.synchronizeData()
            }.catch { error-> Void in
                
                super.synchronizeData()
        }
    }
    
    /// Fetch all notifications
    ///
    /// - Returns: array of notifications
    class func fetch()-> Promise<[TMNotificationGroup]> {
        
        /// Networking request
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "notifications").then { response-> Promise<[TMNotificationGroup]> in
            
            /// Safety check
            guard let groups = response["results"].array else {
                return Promise(value: [])
            }
            
            /// Update global badge number
            UIApplication.shared.applicationIconBadgeNumber = response["unread"].int ?? 0
            
            return TMCoreDataManager.insertASync(Into<TMNotificationGroup>(), source: groups)
        }
    }
    
    class func markAsRead(activities: [TMNotificationActivity]?)-> Promise<[TMNotificationGroup]> {
        
        /// Safety check
        guard let activities = activities, activities.count > 0 else {
            return Promise(value: [])
        }
        
        /// Activities ids
        let activitiesIDs = activities.map { $0.id }
        
        /// Networking request
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "notifications", parameters: ["activities": activitiesIDs]).then { response-> Promise<[TMNotificationGroup]> in
            return fetch()
        }
    }
}
