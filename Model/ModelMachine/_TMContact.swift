// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMContact.swift instead.

import Foundation
import CoreData

public enum TMContactAttributes: String {
    case birthday = "birthday"
    case firstName = "firstName"
    case identifier = "identifier"
    case lastName = "lastName"
    case middleName = "middleName"
    case note = "note"
    case userID = "userID"
}

public enum TMContactRelationships: String {
    case addresses = "addresses"
    case request = "request"
}

open class _TMContact: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMContact"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMContact.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var birthday: Date?

    @NSManaged open
    var firstName: String?

    @NSManaged open
    var identifier: String?

    @NSManaged open
    var lastName: String?

    @NSManaged open
    var middleName: String?

    @NSManaged open
    var note: String?

    @NSManaged open
    var userID: String?

    // MARK: - Relationships

    @NSManaged open
    var addresses: NSOrderedSet

    open func addressesSet() -> NSMutableOrderedSet {
        return self.addresses.mutableCopy() as! NSMutableOrderedSet
    }

    @NSManaged open
    var request: NSSet

    open func requestSet() -> NSMutableSet {
        return self.request.mutableCopy() as! NSMutableSet
    }

}

extension _TMContact {

    open func addAddresses(_ objects: NSOrderedSet) {
        let mutable = self.addresses.mutableCopy() as! NSMutableOrderedSet
        mutable.union(objects)
        self.addresses = mutable.copy() as! NSOrderedSet
    }

    open func removeAddresses(_ objects: NSOrderedSet) {
        let mutable = self.addresses.mutableCopy() as! NSMutableOrderedSet
        mutable.minus(objects)
        self.addresses = mutable.copy() as! NSOrderedSet
    }

    open func addAddressesObject(_ value: TMContactAddress) {
        let mutable = self.addresses.mutableCopy() as! NSMutableOrderedSet
        mutable.add(value)
        self.addresses = mutable.copy() as! NSOrderedSet
    }

    open func removeAddressesObject(_ value: TMContactAddress) {
        let mutable = self.addresses.mutableCopy() as! NSMutableOrderedSet
        mutable.remove(value)
        self.addresses = mutable.copy() as! NSOrderedSet
    }

}

extension _TMContact {

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
