// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMCart.swift instead.

import Foundation
import CoreData

public enum TMCartAttributes: String {
    case destination = "destination"
    case orderID = "orderID"
    case shippingMethod = "shippingMethod"
    case subtotal = "subtotal"
    case total = "total"
    case totalFee = "totalFee"
    case totalShipping = "totalShipping"
    case totalTax = "totalTax"
    case wrappingID = "wrappingID"
}

public enum TMCartRelationships: String {
    case address = "address"
    case items = "items"
    case label = "label"
    case orderType = "orderType"
    case payment = "payment"
    case request = "request"
}

open class _TMCart: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMCart"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMCart.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var destination: String?

    @NSManaged open
    var orderID: String?

    @NSManaged open
    var shippingMethod: String?

    @NSManaged public
    var subtotal: NSNumber?

    @NSManaged public
    var total: NSNumber?

    @NSManaged public
    var totalFee: NSNumber?

    @NSManaged public
    var totalShipping: NSNumber?

    @NSManaged public
    var totalTax: NSNumber?

    @NSManaged open
    var wrappingID: String?

    // MARK: - Relationships

    @NSManaged open
    var address: TMContactAddress?

    @NSManaged open
    var items: NSOrderedSet

    open func itemsSet() -> NSMutableOrderedSet {
        return self.items.mutableCopy() as! NSMutableOrderedSet
    }

    @NSManaged open
    var label: TMCartLabel?

    @NSManaged open
    var orderType: TMShippingType?

    @NSManaged open
    var payment: TMPayment?

    @NSManaged open
    var request: TMRequest?

}

extension _TMCart {

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

    open func addItemsObject(_ value: TMCartItem) {
        let mutable = self.items.mutableCopy() as! NSMutableOrderedSet
        mutable.add(value)
        self.items = mutable.copy() as! NSOrderedSet
    }

    open func removeItemsObject(_ value: TMCartItem) {
        let mutable = self.items.mutableCopy() as! NSMutableOrderedSet
        mutable.remove(value)
        self.items = mutable.copy() as! NSOrderedSet
    }

}
