// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMCartLabel.swift instead.

import Foundation
import CoreData

public enum TMCartLabelAttributes: String {
    case cartID = "cartID"
    case from = "from"
    case note = "note"
    case to = "to"
}

public enum TMCartLabelRelationships: String {
    case cart = "cart"
    case order = "order"
}

open class _TMCartLabel: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMCartLabel"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMCartLabel.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var cartID: String?

    @NSManaged open
    var from: String?

    @NSManaged open
    var note: String?

    @NSManaged open
    var to: String?

    // MARK: - Relationships

    @NSManaged open
    var cart: TMCart?

    @NSManaged open
    var order: TMOrder?

}

