// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMImage.swift instead.

import Foundation
import CoreData

public enum TMImageAttributes: String {
    case imageID = "imageID"
    case itemID = "itemID"
    case src = "src"
}

public enum TMImageRelationships: String {
    case productv = "productv"
    case recommendation = "recommendation"
}

open class _TMImage: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMImage"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMImage.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var imageID: String?

    @NSManaged open
    var itemID: String?

    @NSManaged open
    var src: String?

    // MARK: - Relationships

    @NSManaged open
    var productv: TMProduct?

    @NSManaged open
    var recommendation: TMRecommendation?

}

