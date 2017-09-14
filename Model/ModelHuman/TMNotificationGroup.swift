//
//  TMNotificationGroup.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON

public struct TMNotificationGroupJSON {
    
    static let activityCount = "activity_count"
    static let actorCount = "actor_count"
    static let group = "group"
    static let verb = "verb"
    static let activities = "activities"
    static let isRead = "is_read"
}

@objc(TMNotificationGroup)
public class TMNotificationGroup: _TMNotificationGroup {

    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        try super.updateModel(with: source, transaction: transaction)
     
        /// Activity count
        activityCount = source[TMNotificationGroupJSON.activityCount].number
        
        /// Actor count
        actorCount = source[TMNotificationGroupJSON.actorCount].number
        
        /// Group
        group = source[TMNotificationGroupJSON.group].string
        
        /// Is read
        isRead = source[TMNotificationGroupJSON.isRead].number
        
        /// Verb
        verb = source[TMNotificationGroupJSON.verb].string
        
        /// Activities
        let activitiesJSONArray = source[TMNotificationGroupJSON.activities].array ?? []
        let tempActivities = try transaction.importUniqueObjects(Into<TMNotificationActivity>(), sourceArray: activitiesJSONArray)

        addActivity(NSSet(array: tempActivities))
    }
}
