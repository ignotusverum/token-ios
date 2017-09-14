// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMCartAddress.swift instead.

import Foundation
import CoreData

public enum TMCartAddressAttributes: String {
    case cartID = "cartID"
    case city = "city"
    case company = "company"
    case country = "country"
    case label = "label"
    case name = "name"
    case sourceID = "sourceID"
    case state = "state"
    case street1 = "street1"
    case street2 = "street2"
    case verified = "verified"
    case zip = "zip"
}

public enum TMCartAddressRelationships: String {
    case cart = "cart"
}

open class _TMCartAddress: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMCartAddress"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMCartAddress.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var cartID: String?

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
    var sourceID: String?

    @NSManaged open
    var state: String?

    @NSManaged open
    var street1: String?

    @NSManaged open
    var street2: String?

    @NSManaged public
    var verified: NSNumber?

    @NSManaged open
    var zip: String?

    // MARK: - Relationships

    @NSManaged open
    var cart: TMCart?

}

