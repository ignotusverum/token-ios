// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMNotificationActivity.swift instead.

import Foundation
import CoreData

public enum TMNotificationActivityAttributes: String {
    case actor = "actor"
    case id = "id"
    case message = "message"
    case object = "object"
    case requestID = "requestID"
    case verb = "verb"
}

public enum TMNotificationActivityRelationships: String {
    case group = "group"
    case request = "request"
}

open class _TMNotificationActivity: TMManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "TMNotificationActivity"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMNotificationActivity.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var actor: String?

    @NSManaged open
    var id: String!

    @NSManaged open
    var message: String?

    @NSManaged open
    var object: String?

    @NSManaged open
    var requestID: String?

    @NSManaged open
    var verb: String?

    // MARK: - Relationships

    @NSManaged open
    var group: TMNotificationGroup?

    @NSManaged open
    var request: TMRequest?

}

