//
//  TMProduct.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON
import PromiseKit

/// Struct that represent Recommendation JSON keys
public struct TMProductJSON {
    
    static let vendorID = "vendor_id"
    static let title = "title"
    static let caption = "caption"
    static let price = "price"
    static let currency = "currency"
    static let images = "images"
    static let description = "description"
}

@objc(TMProduct)
open class TMProduct: _TMProduct {

    // Convert min value to dollars
    var copyPriceString: String {
    
        guard let price = price else {
            return ""
        }
        
        return "$\(price)"
    }
    
    // Images Array
    var imagesArray: [TMImage] {
        
        return images.array as? [TMImage] ?? []
    }
    
    // Primary Image
    var primaryImage: TMImage? {
        
        return imagesArray.first
    }
    
    // MARK: - Utilities
    func getAnalyticsDict()-> [String: Any] {
        
        var resultDict = [String: Any]()
        
        if let modelID = self.id {
            
            resultDict["id"] = modelID
        }
        
        if let name = self.title {
            
            resultDict["name"] = name
        }
        
        if let price = self.price {
            
            resultDict["price"] = price.intValue
        }
        
        return resultDict
    }
    
    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        try super.updateModel(with: source, transaction: transaction)
        
        // Local updated date
        self.localUpdatedAt = Date()
        
        // Vendor ID
        self.vendorID = source[TMProductJSON.vendorID].string
        
        // Title
        self.title = source[TMProductJSON.title].string
        
        // Caption
        self.caption = source[TMProductJSON.caption].string
        
        /// Price
        self.price = source[TMProductJSON.price].price
        
        // Currency
        self.currency = source[TMProductJSON.currency].string
        
        // Description
        self.productDescription = source[TMProductJSON.description].string
        
        // Fetch Images
        let imagesJSONArray = source[TMProductJSON.images].array ?? []
        let tempImages = try transaction.importUniqueObjects(Into<TMImage>(), sourceArray: imagesJSONArray)
        self.images = NSOrderedSet(array: tempImages)
    }
}
