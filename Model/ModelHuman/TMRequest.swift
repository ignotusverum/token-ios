
//
//  TMRequest.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import PromiseKit
import SwiftyJSON
import IGListKit

/// Struct that represent Request JSON keys
public struct TMRequestJSON {
    
    static let id = "id"
    static let userID = "user_id"
    static let cartID = "cart_id"
    static let contactID = "contact_id"
    static let channelID = "channel_id"
    
    static let status = "status"
    static let occasion = "occasion"
    
    static let receiverName = "receiver_name"
    
    static let age = "age"
    static let location = "location"
    static let relation = "relation"
    
    static let description = "description"
    
    static let priceLow = "price_low"
    static let priceHigh = "price_high"
    
    static let displayStatus = "display_status"
}

enum RequestStatus: String {
    // Gold gradient
    case pending = "pending"
    
    // Pink Color
    case selection = "ready"
    
    case purchase = "ordered"
    case shipment = "shipped"
    case delivery = "delivered"
    
    /// Possible crash if you change capacity of those arrays
    static let allValues = [pending, selection, purchase, shipment, delivery]
    static let allStatuses = ["pending", "ready", "ordered", "shipped", "delivered"]
    static let allColors = [UIColor.firstGradientColor, UIColor.TMPinkColor, UIColor.darkPinkNormal, UIColor.firstGradientColor, UIColor.TMBlackColor]
    static let allDisplayStatuses = ["looking", "gifts ready", "ordered", "shipped", "delivered"]
    
    static let allCopies = ["We’ll report back promptly with wonderful gifts for ____.", "We’ve found you wonderful gifts. Take a look.", "How thoughtful! We’ll update you when your gift ships. Cheers!", "Your gift is on its way. We’ll update you when it is delivered.", "Your gift has been delivered. We hope ____ enjoys it!"]
}

@objc(TMRequest)
open class TMRequest: _TMRequest {
    
    var receiverNameDisplay: String? {
        return self.receiverName
    }
    
    // Attributes array
    var attributesArray: [TMRequestAttribute] {
        
        return self.attributes.allObjects as? [TMRequestAttribute] ?? []
    }
    
    /// Activities
    var activitiesArray: [TMNotificationActivity] {
        
        var result: [TMNotificationActivity] = self.activities.allObjects as? [TMNotificationActivity] ?? []

        /// Filter
        result = result.filter { $0.group?.isRead?.boolValue == false || $0.group?.isRead == nil }
        
        return result
    }
    
    /// Conversation activities
    var conversationActivities: [TMNotificationActivity] {
        
        /// Current request
        let currentRequest = Where("\(TMNotificationActivityAttributes.requestID.rawValue) == %@", self.id)
        
        /// Conversations verb
        let conversation = Where("\(TMNotificationActivityAttributes.verb.rawValue) == %@", "sent")
        
        /// Unread groups only
        let unread = Where("\(TMNotificationActivityRelationships.group.rawValue).\(TMNotificationGroupAttributes.isRead.rawValue) == nil")
        
        let result = TMCoreDataManager.defaultStack.fetchAll(From<TMNotificationActivity>(), currentRequest && conversation && unread)
        
        return result ?? []
    }
    
    var recommendationActivities: [TMNotificationActivity] {
        
        /// Current request
        let currentRequest = Where("\(TMNotificationActivityAttributes.requestID.rawValue) == %@", self.id)
        
        /// Conversations verb
        let conversation = Where("\(TMNotificationActivityAttributes.verb.rawValue) == %@", "published")
        
        /// Unread groups only
        let unread = Where("\(TMNotificationActivityRelationships.group.rawValue).\(TMNotificationGroupAttributes.isRead.rawValue) == nil")
        
        let result = TMCoreDataManager.defaultStack.fetchAll(From<TMNotificationActivity>(), currentRequest && conversation && unread)
        
        return result ?? []
    }
    
    /// Conversations count
    var conversationNotificationCount: Int {
        
        /// If count > 0 show 1
        return conversationActivities.count > 0 ? 1 : 0
    }
    
    /// Recommendation count
    var recommendationCount: Int {
        
        /// If count > 0 show 1
        return recommendationActivities.count > 0 ? 1 : 0
    }
    
    // Checkout status
    var isCheckoutAvaliable: Bool {
        
        if self.status != .selection && self.status != .pending {
            return false
        }
        
        return true
    }
    
    // Recommendation array
    var recommendationArray: [TMRecommendation] {
    
        return self.recommendations.array as? [TMRecommendation] ?? []
    }
    
    // Recommendations array for status controller
    var recommendationArrayReversed: [TMRecommendation] {
        
        return self.recommendationArray.reversed()
    }
    
    var numberOfItems: Int {
    
        if self.recommendations.count > 0 {
            
            var resultCount = 0
            
            let latest = self.recommendationArray.last
            
            if latest != nil {
                
                resultCount = (latest?.itemsArray.count)!
            }
            
            return resultCount
        }
        
        return 0
    }
    
    var requestDetailsString: String? {
        
        if var resultString = self.occasion {
        
            if resultString.length > 0 {
                resultString = resultString + " |"
            }
            
            resultString = resultString + self.priceRangeString
            
            return resultString
        }
        
        return nil
    }
    
    var priceRangeString: String {
    
        var resultString = "$"
        
        if let lowerString = self.priceLow?.stringValue {
            
            resultString = resultString + lowerString
        }
        else {
            
            resultString = resultString + "0"
        }
        
        if let highString = self.priceHigh?.stringValue {
            
            resultString = resultString + "-" + highString
        }
        
        // TODO: Add values from /me when implemented
        if self.priceLow?.stringValue == self.priceHigh?.stringValue {
            
            return "$500+"
        }
        
        return resultString
    }
    
    var status: RequestStatus {
        
        guard let statusString = statusString,
            let index = RequestStatus.allStatuses.index(of: statusString) else {
                
            return .pending
        }
        
        return RequestStatus.allValues[index]
    }
    
    var statusCopyString: String? {
    
        if recommendations.array.count > 0 && status == .selection {
            
            guard let _contact = contact else {
                
                return ("Token has found \(numberOfItems) great gifts.\nCheck them out now!")
            }
            
            return ("Token has found \(numberOfItems) great gifts for \(_contact.availableName).\nCheck them out now!")
        }
        
        return ""
    }

    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        try super.updateModel(with: source, transaction: transaction)
        
        // User ID
        self.userID = source[TMRequestJSON.userID].string
        
        // Cart ID
        self.cartID = source[TMRequestJSON.cartID].string
        
        // Receiver Name
        self.receiverName = source[TMRequestJSON.receiverName].string
        
        // Contact ID
        self.contactID = source[TMRequestJSON.contactID].string
        if let contactID = contactID, contact == nil {
            
            self.contact = transaction.fetchOne(From<TMContact>(), Where("\(TMModelAttributes.id.rawValue) == %@", contactID))
        }
        
        // Channel ID
        self.channelID = source[TMRequestJSON.channelID].string
        
        // Occasion
        self.occasion = source[TMRequestJSON.occasion].string
        
        // Age
        self.age = source[TMRequestJSON.age].string
        
        // Location
        self.location = source[TMRequestJSON.location].string

        // Relation
        self.relation = source[TMRequestJSON.relation].string
  
        // Description
        self.requestDescription = source[TMRequestJSON.description].string
        
        // Price Low
        self.priceLow = source[TMRequestJSON.priceLow].number
        
        // Price Hight
        self.priceHigh = source[TMRequestJSON.priceHigh].number

        // Display Status
        self.displayStatus = source[TMRequestJSON.displayStatus].string
        
        // Status
        self.statusString = source[TMRequestJSON.status].string
    }
}

// MARK: - IGListDiffable
extension TMRequest: IGListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: IGListDiffable?) -> Bool {
        
        guard let request = object as? TMRequest else {
            print("Object is not a Request type.")
            
            return false
        }
        
        return id == request.id
    }
}
