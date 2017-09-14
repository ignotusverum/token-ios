// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMUser.swift instead.

import Foundation
import CoreData

public enum TMUserAttributes: String {
    case email = "email"
    case firstName = "firstName"
    case lastName = "lastName"
    case phoneNumberFormatted = "phoneNumberFormatted"
    case phoneNumberRaw = "phoneNumberRaw"
    case profileURLString = "profileURLString"
    case userName = "userName"
}

public enum TMUserRelationships: String {
    case addresses = "addresses"
    case cards = "cards"
}

open class _TMUser: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMUser"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMUser.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var email: String?

    @NSManaged open
    var firstName: String?

    @NSManaged open
    var lastName: String?

    @NSManaged open
    var phoneNumberFormatted: String?

    @NSManaged open
    var phoneNumberRaw: String?

    @NSManaged open
    var profileURLString: String?

    @NSManaged open
    var userName: String?

    // MARK: - Relationships

    @NSManaged open
    var addresses: NSOrderedSet

    open func addressesSet() -> NSMutableOrderedSet {
        return self.addresses.mutableCopy() as! NSMutableOrderedSet
    }

    @NSManaged open
    var cards: NSOrderedSet

    open func cardsSet() -> NSMutableOrderedSet {
        return self.cards.mutableCopy() as! NSMutableOrderedSet
    }

}

extension _TMUser {

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

extension _TMUser {

    open func addCards(_ objects: NSOrderedSet) {
        let mutable = self.cards.mutableCopy() as! NSMutableOrderedSet
        mutable.union(objects)
        self.cards = mutable.copy() as! NSOrderedSet
    }

    open func removeCards(_ objects: NSOrderedSet) {
        let mutable = self.cards.mutableCopy() as! NSMutableOrderedSet
        mutable.minus(objects)
        self.cards = mutable.copy() as! NSOrderedSet
    }

    open func addCardsObject(_ value: TMPayment) {
        let mutable = self.cards.mutableCopy() as! NSMutableOrderedSet
        mutable.add(value)
        self.cards = mutable.copy() as! NSOrderedSet
    }

    open func removeCardsObject(_ value: TMPayment) {
        let mutable = self.cards.mutableCopy() as! NSMutableOrderedSet
        mutable.remove(value)
        self.cards = mutable.copy() as! NSOrderedSet
    }

}
