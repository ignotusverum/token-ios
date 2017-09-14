// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMShippingType.swift instead.

import Foundation
import CoreData

public enum TMShippingTypeAttributes: String {
    case active = "active"
    case displayPrice = "displayPrice"
    case imageString = "imageString"
    case order = "order"
    case title = "title"
    case typeDescription = "typeDescription"
}

public enum TMShippingTypeRelationships: String {
    case cart = "cart"
}

open class _TMShippingType: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMShippingType"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMShippingType.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var active: NSNumber?

    @NSManaged open
    var displayPrice: String?

    @NSManaged open
    var imageString: String?

    @NSManaged public
    var order: NSNumber?

    @NSManaged open
    var title: String?

    @NSManaged open
    var typeDescription: String?

    // MARK: - Relationships

    @NSManaged open
    var cart: TMCart?

}

