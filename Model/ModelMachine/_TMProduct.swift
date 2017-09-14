// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TMProduct.swift instead.

import Foundation
import CoreData

public enum TMProductAttributes: String {
    case caption = "caption"
    case currency = "currency"
    case localUpdatedAt = "localUpdatedAt"
    case price = "price"
    case productDescription = "productDescription"
    case title = "title"
    case vendorID = "vendorID"
}

public enum TMProductRelationships: String {
    case cartItem = "cartItem"
    case images = "images"
    case item = "item"
    case lineItem = "lineItem"
}

open class _TMProduct: TMModel {

    // MARK: - Class methods

    override open class func entityName () -> String {
        return "TMProduct"
    }

    override open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TMProduct.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var caption: String?

    @NSManaged open
    var currency: String?

    @NSManaged open
    var localUpdatedAt: Date?

    @NSManaged public
    var price: NSNumber?

    @NSManaged open
    var productDescription: String?

    @NSManaged open
    var title: String?

    @NSManaged open
    var vendorID: String?

    // MARK: - Relationships

    @NSManaged open
    var cartItem: NSOrderedSet

    open func cartItemSet() -> NSMutableOrderedSet {
        return self.cartItem.mutableCopy() as! NSMutableOrderedSet
    }

    @NSManaged open
    var images: NSOrderedSet

    open func imagesSet() -> NSMutableOrderedSet {
        return self.images.mutableCopy() as! NSMutableOrderedSet
    }

    @NSManaged open
    var item: NSSet

    open func itemSet() -> NSMutableSet {
        return self.item.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var lineItem: TMLineItem?

}

extension _TMProduct {

    open func addCartItem(_ objects: NSOrderedSet) {
        let mutable = self.cartItem.mutableCopy() as! NSMutableOrderedSet
        mutable.union(objects)
        self.cartItem = mutable.copy() as! NSOrderedSet
    }

    open func removeCartItem(_ objects: NSOrderedSet) {
        let mutable = self.cartItem.mutableCopy() as! NSMutableOrderedSet
        mutable.minus(objects)
        self.cartItem = mutable.copy() as! NSOrderedSet
    }

    open func addCartItemObject(_ value: TMCartItem) {
        let mutable = self.cartItem.mutableCopy() as! NSMutableOrderedSet
        mutable.add(value)
        self.cartItem = mutable.copy() as! NSOrderedSet
    }

    open func removeCartItemObject(_ value: TMCartItem) {
        let mutable = self.cartItem.mutableCopy() as! NSMutableOrderedSet
        mutable.remove(value)
        self.cartItem = mutable.copy() as! NSOrderedSet
    }

}

extension _TMProduct {

    open func addImages(_ objects: NSOrderedSet) {
        let mutable = self.images.mutableCopy() as! NSMutableOrderedSet
        mutable.union(objects)
        self.images = mutable.copy() as! NSOrderedSet
    }

    open func removeImages(_ objects: NSOrderedSet) {
        let mutable = self.images.mutableCopy() as! NSMutableOrderedSet
        mutable.minus(objects)
        self.images = mutable.copy() as! NSOrderedSet
    }

    open func addImagesObject(_ value: TMImage) {
        let mutable = self.images.mutableCopy() as! NSMutableOrderedSet
        mutable.add(value)
        self.images = mutable.copy() as! NSOrderedSet
    }

    open func removeImagesObject(_ value: TMImage) {
        let mutable = self.images.mutableCopy() as! NSMutableOrderedSet
        mutable.remove(value)
        self.images = mutable.copy() as! NSOrderedSet
    }

}

extension _TMProduct {

    open func addItem(_ objects: NSSet) {
        let mutable = self.item.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        self.item = mutable.copy() as! NSSet
    }

    open func removeItem(_ objects: NSSet) {
        let mutable = self.item.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        self.item = mutable.copy() as! NSSet
    }

    open func addItemObject(_ value: TMItem) {
        let mutable = self.item.mutableCopy() as! NSMutableSet
        mutable.add(value)
        self.item = mutable.copy() as! NSSet
    }

    open func removeItemObject(_ value: TMItem) {
        let mutable = self.item.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        self.item = mutable.copy() as! NSSet
    }

}
