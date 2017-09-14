// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMLineItem.swift instead.

import Foundation
import CoreData

public enum TMLineItemAttributes: String {
    case currency = "currency"
    case ownerID = "ownerID"
    case ownerType = "ownerType"
    case price = "price"
    case productID = "productID"
    case quantity = "quantity"
    case shippingRequired = "shippingRequired"
    case sku = "sku"
    case taxable = "taxable"
    case title = "title"
    case variantID = "variantID"
}

public enum TMLineItemRelationships: String {
    case order = "order"
    case product = "product"
}

open class _TMLineItem: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMLineItem"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMLineItem.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var currency: String?

    @NSManaged open
    var ownerID: String?

    @NSManaged open
    var ownerType: String?

    @NSManaged public
    var price: NSNumber?

    @NSManaged open
    var productID: String?

    @NSManaged public
    var quantity: NSNumber?

    @NSManaged public
    var shippingRequired: NSNumber?

    @NSManaged open
    var sku: String?

    @NSManaged public
    var taxable: NSNumber?

    @NSManaged open
    var title: String?

    @NSManaged open
    var variantID: String?

    // MARK: - Relationships

    @NSManaged open
    var order: TMOrder?

    @NSManaged open
    var product: TMProduct?

}

