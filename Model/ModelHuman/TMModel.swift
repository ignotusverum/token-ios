//
//  TMModel.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import SwiftyJSON

import PromiseKit
import CoreStore

/// Struct that represent model JSON keys
public struct TMModelJSON {
    
    static let id = "id"
    static let createdAt = "created_at"
    static let updatedAt = "updated_at"
}

@objc(TMModel)
open class TMModel: _TMModel, ImportableUniqueObject {
    
    var json: JSON?
    
    // MARK: - Importable Source Protocol
    public typealias ImportSource = JSON
    
    // Unique ID key
    public static var uniqueIDKeyPath: String {
        return "id"
    }
    
    // Unique ID Type
    public typealias UniqueIDType = NSString

    public var uniqueIDValue: NSString {
        get { return NSString(string: self.id) }
        set { self.id = newValue as String! }
    }
    
    // Unique ID value
    public static func shouldInsert(from source: JSON, in transaction: BaseDataTransaction) -> Bool {
        
        if let id = source["id"].string {
            
            let object = transaction.fetchOne(From<TMModel>(),
                                            Where("\(TMModelJSON.id) == %@", id))
            
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
        
        return source["id"].nsString
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
        self.id = source[TMModelJSON.id].string ?? ""
        
        // Created at
        self.createdAt = source[TMModelJSON.createdAt].dateTime
        
        // Updated at
        self.updatedAt = source[TMModelJSON.updatedAt].dateTime
    }
}
