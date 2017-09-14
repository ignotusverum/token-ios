//
//  TMRequestAttribute.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON

/// Struct that represent RequestAttribute JSON keys
public struct TMRequestAttributeJSON {
    
    static let category = "category"
    static let name = "name"
    static let image = "image"
}

@objc(TMRequestAttribute)
open class TMRequestAttribute: _TMRequestAttribute {
    
    var imageURL: URL? {
        
        if self.imageURLString != nil {
            return URL(string: self.imageURLString!)
        }
        
        return nil
    }
    var selected = false
    
    var image: UIImage?
    
    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        try super.updateModel(with: source, transaction: transaction)
        
        // Category
        self.category = source[TMRequestAttributeJSON.category].string
        
        // Name
        self.name = source[TMRequestAttributeJSON.name].string
        
        // Image
        self.imageURLString = source[TMRequestAttributeJSON.image].string
    }
}
