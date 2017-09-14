// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMPayment.swift instead.

import Foundation
import CoreData

public enum TMPaymentAttributes: String {
    case brand = "brand"
    case expirationMonth = "expirationMonth"
    case expirationYear = "expirationYear"
    case externalID = "externalID"
    case fingerprint = "fingerprint"
    case isDefault = "isDefault"
    case label = "label"
    case last4 = "last4"
    case postal = "postal"
    case provider = "provider"
    case type = "type"
    case userID = "userID"
}

public enum TMPaymentRelationships: String {
    case cart = "cart"
    case order = "order"
    case user = "user"
}

open class _TMPayment: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMPayment"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMPayment.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var brand: String?

    @NSManaged open
    var expirationMonth: String?

    @NSManaged open
    var expirationYear: String?

    @NSManaged open
    var externalID: String?

    @NSManaged open
    var fingerprint: String?

    @NSManaged public
    var isDefault: NSNumber?

    @NSManaged open
    var label: String?

    @NSManaged open
    var last4: String?

    @NSManaged open
    var postal: String?

    @NSManaged open
    var provider: String?

    @NSManaged open
    var type: AnyObject?

    @NSManaged open
    var userID: String?

    // MARK: - Relationships

    @NSManaged open
    var cart: TMCart?

    @NSManaged open
    var order: TMOrder?

    @NSManaged open
    var user: TMUser?

}

