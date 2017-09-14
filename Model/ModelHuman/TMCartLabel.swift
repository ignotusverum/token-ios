//
//  TMCartLabel.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON

/// Struct that represent Cart Label JSON keys
public struct TMCartLabelJSON {
    
    static let cartID = "cart_id"
    static let from = "from"
    static let note = "message"
    static let to = "to"
}

@objc(TMCartLabel)
open class TMCartLabel: _TMCartLabel {

    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        try super.updateModel(with: source, transaction: transaction)
        
        // Cart ID
        cartID = source[TMCartLabelJSON.cartID].string
        
        // From
        from = source[TMCartLabelJSON.from].string
        
        // To
        to = source[TMCartLabelJSON.to].string
        
        // Note
        note = source[TMCartLabelJSON.note].string
    }
}
