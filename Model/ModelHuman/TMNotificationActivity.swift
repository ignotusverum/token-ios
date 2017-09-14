//
//  TMNotificationActivity.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON

public struct TMNotificationActivityJSON {
    
    static let id = "id"
    static let actor = "actor"
    static let verb = "verb"
    static let object = "object"
    static let requestID = "request_id"
    static let message = "message"
    static let metadata = "metadata"
}

@objc(TMNotificationActivity)
public class TMNotificationActivity: _TMNotificationActivity, ImportableUniqueObject {
    
    var json: JSON?
    
    // MARK: - Importable Source Protocol
    public typealias ImportSource = JSON
    
    // Unique ID key
    public static var uniqueIDKeyPath: String {
        return TMNotificationActivityJSON.id
    }
    
    // Unique ID Type
    public typealias UniqueIDType = NSString
    
    public var uniqueIDValue: NSString {
        get { return NSString(string: self.id) }
        set { self.id = newValue as String! }
    }
    
    // Unique ID value
    public static func shouldInsert(from source: JSON, in transaction: BaseDataTransaction) -> Bool {
        
        if let id = source[TMNotificationActivityJSON.id].string {
            
            let object = transaction.fetchOne(From<TMNotificationActivity>(),
                                              Where("\(TMNotificationActivityAttributes.id) == %@", id))
            
            if object != nil {
                
                return false
            }
        }
        
        return true
    }
    
    // Update object with importable source
    public static func shouldUpdate(from source: JSON, in transaction: BaseDataTransaction) -> Bool {
        
        return true
    }
    
    public static func uniqueID(from source: JSON, in transaction: BaseDataTransaction) throws -> NSString? {
        
        return source[TMNotificationActivityJSON.id].nsString
    }
    
    public func update(from source: JSON, in transaction: BaseDataTransaction) throws {
        
        try self.updateModel(with: source, transaction: transaction)
    }
    
    // New object created
    public func didInsert(from source: JSON, in transaction: BaseDataTransaction) throws {
        
        try self.updateModel(with: source, transaction: transaction)
    }
    
    public func updateFromImportSource(_ source: JSON, inTransaction transaction: BaseDataTransaction) throws {
        
        try self.updateModel(with: source, transaction: transaction)
    }
    
    func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        // ID
        id = source[TMModelJSON.id].string ?? ""
        
        /// Actor
        actor = source[TMNotificationActivityJSON.actor].string
        
        /// Verb
        verb = source[TMNotificationActivityJSON.verb].string
        
        /// Object
        object = source[TMNotificationActivityJSON.object].string
        
        /// Metadata
        if let metadataJSON = source[TMNotificationActivityJSON.metadata].json {
            
            /// Request ID
            requestID = metadataJSON[TMNotificationActivityJSON.requestID].string
            
            /// Request
            request = transaction.fetchOne(From<TMModel>(), Where("\(TMModelJSON.id) == %@", requestID ?? "")) as? TMRequest
            
            /// Message
            message = metadataJSON[TMNotificationActivityJSON.message].string
        }
    }
}
