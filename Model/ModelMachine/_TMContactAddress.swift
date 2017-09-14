// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMContactAddress.swift instead.

import Foundation
import CoreData

public enum TMContactAddressAttributes: String {
    case city = "city"
    case company = "company"
    case country = "country"
    case label = "label"
    case name = "name"
    case state = "state"
    case street = "street"
    case street2 = "street2"
    case userID = "userID"
    case zip = "zip"
}

public enum TMContactAddressRelationships: String {
    case cart = "cart"
    case contact = "contact"
    case order = "order"
    case user = "user"
}

open class _TMContactAddress: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMContactAddress"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMContactAddress.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var city: String?

    @NSManaged open
    var company: String?

    @NSManaged open
    var country: String?

    @NSManaged open
    var label: String?

    @NSManaged open
    var name: String?

    @NSManaged open
    var state: String?

    @NSManaged open
    var street: String?

    @NSManaged open
    var street2: String?

    @NSManaged open
    var userID: String?

    @NSManaged open
    var zip: String?

    // MARK: - Relationships

    @NSManaged open
    var cart: TMCart?

    @NSManaged open
    var contact: TMContact?

    @NSManaged open
    var order: TMOrder?

    @NSManaged open
    var user: TMUser?

}

