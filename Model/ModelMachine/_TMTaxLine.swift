// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMTaxLine.swift instead.

import Foundation
import CoreData

public enum TMTaxLineAttributes: String {
    case currency = "currency"
    case ownerID = "ownerID"
    case ownerType = "ownerType"
    case price = "price"
    case rate = "rate"
    case title = "title"
}

public enum TMTaxLineRelationships: String {
    case order = "order"
}

open class _TMTaxLine: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMTaxLine"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMTaxLine.entity(managedObjectContext) else { return nil }
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

    @NSManaged public
    var rate: NSNumber?

    @NSManaged open
    var title: String?

    // MARK: - Relationships

    @NSManaged open
    var order: TMOrder?

}

