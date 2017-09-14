// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMRequestAttribute.swift instead.

import Foundation
import CoreData

public enum TMRequestAttributeAttributes: String {
    case category = "category"
    case imageURLString = "imageURLString"
    case name = "name"
}

public enum TMRequestAttributeRelationships: String {
    case request = "request"
}

open class _TMRequestAttribute: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMRequestAttribute"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMRequestAttribute.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var category: String?

    @NSManaged open
    var imageURLString: String?

    @NSManaged open
    var name: String?

    // MARK: - Relationships

    @NSManaged open
    var request: NSSet

    open func requestSet() -> NSMutableSet {
        return self.request.mutableCopy() as! NSMutableSet
    }

}

extension _TMRequestAttribute {

    open func addRequest(_ objects: NSSet) {
        let mutable = self.request.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.request = mutable.copy() as! NSSet
    }

    open func removeRequest(_ objects: NSSet) {
        let mutable = self.request.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.request = mutable.copy() as! NSSet
    }

    open func addRequestObject(_ value: TMRequest) {
        let mutable = self.request.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.request = mutable.copy() as! NSSet
    }

    open func removeRequestObject(_ value: TMRequest) {
        let mutable = self.request.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.request = mutable.copy() as! NSSet
    }

}
