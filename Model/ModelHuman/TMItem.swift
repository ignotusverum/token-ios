//
//  TMItem.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON

/// Struct that represent Recommendation JSON keys
public struct TMItemJSON {
    
    static let description = "description"
    static let recommendationID = "recommendation_id"
    static let productID = "product_id"
    static let title = "title"
    static let rating = "rating"
}

@objc(TMItem)
open class TMItem: _TMItem {

    // Rating enum
    var feedbackType: TMFeedbackType {
        
        guard let rating = rating else {
            return .inactive
        }
        
        switch rating {
        case 1:
            return .remove
        case 2:
            return .negative
        case 3:
            return .neutral
        case 4:
            return .positive
        case 5:
            return .love
        default:
            return .inactive
        }
    }
    
    // Transforming to JSON
    func transformToJSON()-> [String: Any] {
        
        var resultDictionary = [String: Any]()
        
        resultDictionary[TMModelJSON.id] = id
        
        if let rating = self.rating {
            
            resultDictionary[TMItemJSON.rating] = rating.intValue
        }
        
        return resultDictionary
    }
    
    func toJSON(quantity: Int)-> [String: Any] {
        
        var resultDictionary = [String: Any]()
        
        if let cartID = self.recommendation!.request!.cartID {
            
            resultDictionary["cart_id"] = cartID
        }
        
        if let productID = self.product?.id {
            
            resultDictionary["product_id"] = productID
        }
        
        resultDictionary["quantity"] = quantity
        
        return resultDictionary
    }
    
	// MARK: - Fetching logic
    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        try super.updateModel(with: source, transaction: transaction)
        
        // Description
        itemDescription = source[TMItemJSON.description].string
        
        // Recommendation ID
        recommendationID = source[TMItemJSON.recommendationID].string
        
        // Product ID
        productID = source[TMItemJSON.productID].string
        
        // Title
        title = source[TMItemJSON.title].string
        
        // Rating
        rating = source[TMItemJSON.rating].number ?? NSNumber(value: 0)
        
        /// Is removed state
        let removedCheck = rating?.intValue == TMFeedbackType.remove.rawValue
        isRemoved = NSNumber(value: removedCheck)
    }
}
