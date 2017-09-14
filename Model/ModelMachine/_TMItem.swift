// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMItem.swift instead.

import Foundation
import CoreData

public enum TMItemAttributes: String {
    case isRemoved = "isRemoved"
    case itemDescription = "itemDescription"
    case productID = "productID"
    case rating = "rating"
    case recommendationID = "recommendationID"
    case title = "title"
}

public enum TMItemRelationships: String {
    case product = "product"
    case recommendation = "recommendation"
}

open class _TMItem: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMItem"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMItem.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var isRemoved: NSNumber?

    @NSManaged open
    var itemDescription: String?

    @NSManaged open
    var productID: String?

    @NSManaged public
    var rating: NSNumber?

    @NSManaged open
    var recommendationID: String?

    @NSManaged open
    var title: String?

    // MARK: - Relationships

    @NSManaged open
    var product: TMProduct?

    @NSManaged open
    var recommendation: TMRecommendation?

}

