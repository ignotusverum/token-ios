// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMNotificationGroup.swift instead.

import Foundation
import CoreData

public enum TMNotificationGroupAttributes: String {
    case activityCount = "activityCount"
    case actorCount = "actorCount"
    case group = "group"
    case isRead = "isRead"
    case verb = "verb"
}

public enum TMNotificationGroupRelationships: String {
    case activity = "activity"
}

open class _TMNotificationGroup: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMNotificationGroup"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMNotificationGroup.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var activityCount: NSNumber?

    @NSManaged public
    var actorCount: NSNumber?

    @NSManaged open
    var group: String?

    @NSManaged public
    var isRead: NSNumber?

    @NSManaged open
    var verb: String?

    // MARK: - Relationships

    @NSManaged open
    var activity: NSSet

    open func activitySet() -> NSMutableSet {
        return self.activity.mutableCopy() as! NSMutableSet
    }

}

extension _TMNotificationGroup {

    open func addActivity(_ objects: NSSet) {
        let mutable = self.activity.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.activity = mutable.copy() as! NSSet
    }

    open func removeActivity(_ objects: NSSet) {
        let mutable = self.activity.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.activity = mutable.copy() as! NSSet
    }

    open func addActivityObject(_ value: TMNotificationActivity) {
        let mutable = self.activity.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.activity = mutable.copy() as! NSSet
    }

    open func removeActivityObject(_ value: TMNotificationActivity) {
        let mutable = self.activity.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.activity = mutable.copy() as! NSSet
    }

}
