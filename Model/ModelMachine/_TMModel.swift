// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMModel.swift instead.

import Foundation
import CoreData

public enum TMModelAttributes: String {
    case createdAt = "createdAt"
    case id = "id"
    case updatedAt = "updatedAt"
}

open class _TMModel: TMManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "TMModel"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMModel.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var createdAt: Date?

    @NSManaged open
    var id: String!

    @NSManaged open
    var updatedAt: Date?

    // MARK: - Relationships

}

