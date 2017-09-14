// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMRequest.swift instead.

import Foundation
import CoreData

public enum TMRequestAttributes: String {
    case age = "age"
    case cartID = "cartID"
    case channelID = "channelID"
    case contactID = "contactID"
    case displayStatus = "displayStatus"
    case location = "location"
    case occasion = "occasion"
    case priceHigh = "priceHigh"
    case priceLow = "priceLow"
    case receiverName = "receiverName"
    case relation = "relation"
    case requestDescription = "requestDescription"
    case seen = "seen"
    case statusString = "statusString"
    case userID = "userID"
}

public enum TMRequestRelationships: String {
    case activities = "activities"
    case attributes = "attributes"
    case cart = "cart"
    case contact = "contact"
    case order = "order"
    case recommendations = "recommendations"
}

open class _TMRequest: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMRequest"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMRequest.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var age: String?

    @NSManaged open
    var cartID: String?

    @NSManaged open
    var channelID: String?

    @NSManaged open
    var contactID: String?

    @NSManaged open
    var displayStatus: String?

    @NSManaged open
    var location: String?

    @NSManaged open
    var occasion: String?

    @NSManaged public
    var priceHigh: NSNumber?

    @NSManaged public
    var priceLow: NSNumber?

    @NSManaged open
    var receiverName: String?

    @NSManaged open
    var relation: String?

    @NSManaged open
    var requestDescription: String?

    @NSManaged public
    var seen: NSNumber?

    @NSManaged open
    var statusString: String?

    @NSManaged open
    var userID: String?

    // MARK: - Relationships

    @NSManaged open
    var activities: NSSet

    open func activitiesSet() -> NSMutableSet {
        return self.activities.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var attributes: NSSet

    open func attributesSet() -> NSMutableSet {
        return self.attributes.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var cart: TMCart?

    @NSManaged open
    var contact: TMContact?

    @NSManaged open
    var order: TMOrder?

    @NSManaged open
    var recommendations: NSOrderedSet

    open func recommendationsSet() -> NSMutableOrderedSet {
        return self.recommendations.mutableCopy() as! NSMutableOrderedSet
    }

}

extension _TMRequest {

    open func addActivities(_ objects: NSSet) {
        let mutable = self.activities.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.activities = mutable.copy() as! NSSet
    }

    open func removeActivities(_ objects: NSSet) {
        let mutable = self.activities.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.activities = mutable.copy() as! NSSet
    }

    open func addActivitiesObject(_ value: TMNotificationActivity) {
        let mutable = self.activities.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.activities = mutable.copy() as! NSSet
    }

    open func removeActivitiesObject(_ value: TMNotificationActivity) {
        let mutable = self.activities.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.activities = mutable.copy() as! NSSet
    }

}

extension _TMRequest {

    open func addAttributes(_ objects: NSSet) {
        let mutable = self.attributes.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.attributes = mutable.copy() as! NSSet
    }

    open func removeAttributes(_ objects: NSSet) {
        let mutable = self.attributes.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.attributes = mutable.copy() as! NSSet
    }

    open func addAttributesObject(_ value: TMRequestAttribute) {
        let mutable = self.attributes.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.attributes = mutable.copy() as! NSSet
    }

    open func removeAttributesObject(_ value: TMRequestAttribute) {
        let mutable = self.attributes.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.attributes = mutable.copy() as! NSSet
    }

}

extension _TMRequest {

    open func addRecommendations(_ objects: NSOrderedSet) {
        let mutable = self.recommendations.mutableCopy() as! NSMutableOrderedSet
        mutable.union(objects)
        self.recommendations = mutable.copy() as! NSOrderedSet
    }

    open func removeRecommendations(_ objects: NSOrderedSet) {
        let mutable = self.recommendations.mutableCopy() as! NSMutableOrderedSet
        mutable.minus(objects)
        self.recommendations = mutable.copy() as! NSOrderedSet
    }

    open func addRecommendationsObject(_ value: TMRecommendation) {
        let mutable = self.recommendations.mutableCopy() as! NSMutableOrderedSet
        mutable.add(value)
        self.recommendations = mutable.copy() as! NSOrderedSet
    }

    open func removeRecommendationsObject(_ value: TMRecommendation) {
        let mutable = self.recommendations.mutableCopy() as! NSMutableOrderedSet
        mutable.remove(value)
        self.recommendations = mutable.copy() as! NSOrderedSet
    }

}
