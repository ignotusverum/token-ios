//
//  TMImage.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON

/// Struct that represent Image JSON keys
public struct TMImageJSON {
    
    static let imageID = "image_id"
    static let itemID = "item_id"
    static let src = "src"
}

@objc(TMImage)
open class TMImage: _TMImage {

    var imageURL: URL? {
        
        if self.src != nil {
            return URL(string: self.src!)
        }
        
        return nil
    }
    
    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        try super.updateModel(with: source, transaction: transaction)
        
        // ID
        self.id = source[TMImageJSON.imageID].string ?? ""
        
        // Item ID
        self.itemID = source[TMImageJSON.itemID].string
        
        // Source
        self.src = source[TMImageJSON.src].string
    }
}
