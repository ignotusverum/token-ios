// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMCartItem.swift instead.

import Foundation
import CoreData

public enum TMCartItemAttributes: String {
    case cartID = "cartID"
    case currency = "currency"
    case price = "price"
    case productID = "productID"
    case quantity = "quantity"
    case variantID = "variantID"
}

public enum TMCartItemRelationships: String {
    case cart = "cart"
    case product = "product"
}

open class _TMCartItem: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMCartItem"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMCartItem.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var cartID: String?

    @NSManaged open
    var currency: String?

    @NSManaged public
    var price: NSNumber?

    @NSManaged open
    var productID: String!

    @NSManaged public
    var quantity: NSNumber?

    @NSManaged open
    var variantID: String?

    // MARK: - Relationships

    @NSManaged open
    var cart: TMCart?

    @NSManaged open
    var product: TMProduct?

}

