// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMOrder.swift instead.

import Foundation
import CoreData

public enum TMOrderAttributes: String {
    case currency = "currency"
    case paymentStatus = "paymentStatus"
    case requestID = "requestID"
    case status = "status"
    case subTotal = "subTotal"
    case totalPrice = "totalPrice"
    case totalShipping = "totalShipping"
    case totalTax = "totalTax"
    case userID = "userID"
}

public enum TMOrderRelationships: String {
    case label = "label"
    case lineItems = "lineItems"
    case payment = "payment"
    case request = "request"
    case shippingAddress = "shippingAddress"
    case taxLines = "taxLines"
}

open class _TMOrder: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMOrder"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMOrder.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var currency: String?

    @NSManaged open
    var paymentStatus: String?

    @NSManaged open
    var requestID: String?

    @NSManaged open
    var status: String?

    @NSManaged public
    var subTotal: NSNumber?

    @NSManaged public
    var totalPrice: NSNumber?

    @NSManaged public
    var totalShipping: NSNumber?

    @NSManaged public
    var totalTax: NSNumber?

    @NSManaged open
    var userID: String?

    // MARK: - Relationships

    @NSManaged open
    var label: TMCartLabel?

    @NSManaged open
    var lineItems: NSSet

    open func lineItemsSet() -> NSMutableSet {
        return self.lineItems.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var payment: TMPayment?

    @NSManaged open
    var request: TMRequest?

    @NSManaged open
    var shippingAddress: TMContactAddress?

    @NSManaged open
    var taxLines: NSSet

    open func taxLinesSet() -> NSMutableSet {
        return self.taxLines.mutableCopy() as! NSMutableSet
    }

}

extension _TMOrder {

    open func addLineItems(_ objects: NSSet) {
        let mutable = self.lineItems.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.lineItems = mutable.copy() as! NSSet
    }

    open func removeLineItems(_ objects: NSSet) {
        let mutable = self.lineItems.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.lineItems = mutable.copy() as! NSSet
    }

    open func addLineItemsObject(_ value: TMLineItem) {
        let mutable = self.lineItems.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.lineItems = mutable.copy() as! NSSet
    }

    open func removeLineItemsObject(_ value: TMLineItem) {
        let mutable = self.lineItems.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.lineItems = mutable.copy() as! NSSet
    }

}

extension _TMOrder {

    open func addTaxLines(_ objects: NSSet) {
        let mutable = self.taxLines.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.taxLines = mutable.copy() as! NSSet
    }

    open func removeTaxLines(_ objects: NSSet) {
        let mutable = self.taxLines.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.taxLines = mutable.copy() as! NSSet
    }

    open func addTaxLinesObject(_ value: TMTaxLine) {
        let mutable = self.taxLines.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.taxLines = mutable.copy() as! NSSet
    }

    open func removeTaxLinesObject(_ value: TMTaxLine) {
        let mutable = self.taxLines.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.taxLines = mutable.copy() as! NSSet
    }

}
