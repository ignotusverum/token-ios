 //
 //  TMRecommendation.swift
 //  consumer
 //
 //  Created by Vladislav Zagorodnyuk on 2/3/16.
 //  Copyright Â© 2016 Human Ventures Co. All rights reserved.
 //
 
 import CoreStore
 import SwiftyJSON
 
 /// Struct that represent Recommendation JSON keys
 public struct TMRecommendationJSON {
    
    static let requestID = "request_id"
    static let seen = "seen"
    static let status = "status"
    static let userID = "user_id"
    static let published = "published"
    static let items = "items"
    static let images = "images"
 }
 
 @objc(TMRecommendation)
 open class TMRecommendation: _TMRecommendation {
    
    // Get Array of JSON items
    var arrayOfJSONItems: [[String: Any]]? {
        
        var resultArray = [[String: Any]]()
        
        for item in itemsArray {
            resultArray.append(item.transformToJSON())
        }
        
        return resultArray
    }
    
    /// Not removed items
    var notRemovedItems: [TMItem] {
        return itemsArray.filter { $0.feedbackType != .remove }
    }
    
    // Selected item
    var selectedItem: TMItem?
    
    var itemsArray: [TMItem] {
        return self.items.array as! [TMItem]
    }
    
    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        try super.updateModel(with: source, transaction: transaction)
        
        // Request ID
        self.requestID = source[TMRecommendationJSON.requestID].string
        
        // Seen
        self.seen = source[TMRecommendationJSON.seen].number ?? false
        
        // Status
        self.statusString = source[TMRecommendationJSON.status].string
        
        // User ID
        self.userID = source[TMRecommendationJSON.userID].string
        
        // Published
        self.published = source[TMRecommendationJSON.published].number
        
        // Fetch Items
        let itemsJSONArray = source[TMRecommendationJSON.items].array ?? []
        let tempItems = try transaction.importUniqueObjects(Into<TMItem>(), sourceArray: itemsJSONArray)
        self.addItems(NSOrderedSet(array: tempItems))
        
        // Fetch Images
        let imagesJSONArray = source[TMRecommendationJSON.images].array ?? []
        let tempImages = try transaction.importUniqueObjects(Into<TMImage>(), sourceArray: imagesJSONArray)
        self.addImages(NSOrderedSet(array: tempImages))
    }
 }
