// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMRecommendation.swift instead.

import Foundation
import CoreData

public enum TMRecommendationAttributes: String {
    case published = "published"
    case requestID = "requestID"
    case seen = "seen"
    case statusString = "statusString"
    case userID = "userID"
}

public enum TMRecommendationRelationships: String {
    case images = "images"
    case items = "items"
    case request = "request"
}

open class _TMRecommendation: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMRecommendation"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMRecommendation.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var published: NSNumber?

    @NSManaged open
    var requestID: String?

    @NSManaged public
    var seen: NSNumber?

    @NSManaged open
    var statusString: String?

    @NSManaged open
    var userID: String?

    // MARK: - Relationships

    @NSManaged open
    var images: NSOrderedSet

    open func imagesSet() -> NSMutableOrderedSet {
        return self.images.mutableCopy() as! NSMutableOrderedSet
    }

    @NSManaged open
    var items: NSOrderedSet

    open func itemsSet() -> NSMutableOrderedSet {
        return self.items.mutableCopy() as! NSMutableOrderedSet
    }

    @NSManaged open
    var request: TMRequest?

}

extension _TMRecommendation {

    open func addImages(_ objects: NSOrderedSet) {
        let mutable = self.images.mutableCopy() as! NSMutableOrderedSet
        mutable.union(objects)
        self.images = mutable.copy() as! NSOrderedSet
    }

    open func removeImages(_ objects: NSOrderedSet) {
        let mutable = self.images.mutableCopy() as! NSMutableOrderedSet
        mutable.minus(objects)
        self.images = mutable.copy() as! NSOrderedSet
    }

    open func addImagesObject(_ value: TMImage) {
        let mutable = self.images.mutableCopy() as! NSMutableOrderedSet
        mutable.add(value)
        self.images = mutable.copy() as! NSOrderedSet
    }

    open func removeImagesObject(_ value: TMImage) {
        let mutable = self.images.mutableCopy() as! NSMutableOrderedSet
        mutable.remove(value)
        self.images = mutable.copy() as! NSOrderedSet
    }

}

extension _TMRecommendation {

    open func addItems(_ objects: NSOrderedSet) {
        let mutable = self.items.mutableCopy() as! NSMutableOrderedSet
        mutable.union(objects)
        self.items = mutable.copy() as! NSOrderedSet
    }

    open func removeItems(_ objects: NSOrderedSet) {
        let mutable = self.items.mutableCopy() as! NSMutableOrderedSet
        mutable.minus(objects)
        self.items = mutable.copy() as! NSOrderedSet
    }

    open func addItemsObject(_ value: TMItem) {
        let mutable = self.items.mutableCopy() as! NSMutableOrderedSet
        mutable.add(value)
        self.items = mutable.copy() as! NSOrderedSet
    }

    open func removeItemsObject(_ value: TMItem) {
        let mutable = self.items.mutableCopy() as! NSMutableOrderedSet
        mutable.remove(value)
        self.items = mutable.copy() as! NSOrderedSet
    }

}
