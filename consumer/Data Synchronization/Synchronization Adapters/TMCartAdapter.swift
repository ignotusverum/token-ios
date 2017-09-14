//
//  TMCartAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/26/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON
import PromiseKit

class TMCartAdapter: TMSynchronizerAdapter {

    /// Remove item from cart
    ///
    /// - Parameters:
    ///   - cart: cart object
    ///   - item: item object
    /// - Returns: returns updated cart
    class func removeItem(cart: TMCart, item: TMItem)-> Promise<TMCart?> {
        
        // Safety check
        guard let productID = item.product?.id else {
            return Promise<TMCart?>(value: nil)
        }
        
        let cartItem = TMCoreDataManager.defaultStack.fetchOne(From<TMCartItem>(), Where("productID == %@", productID))
    
        return self.removeCartItem(cart: cart, cartItem: cartItem)
    }
    
    /// Remove cart item call
    ///
    /// - Parameters:
    ///   - cart: cart object
    ///   - cartItem: item object
    /// - Returns: return updated cart
    class func removeCartItem(cart: TMCart, cartItem: TMCartItem?)-> Promise<TMCart?> {
        
        guard let cartItem = cartItem else {
            return Promise(value: nil)
        }
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.delete, path: "carts/\(cart.id!)/items/\(cartItem.id!)").then { response-> Promise<Bool> in
            
            return TMCoreDataManager.deleteASync([cartItem])
            }.then { result-> Promise<TMCart?> in
                
                return TMCoreDataManager.fetchExisting(cart)
        }
    }
    
    /// Update cart item quantity
    ///
    /// - Parameters:
    ///   - cart: object for updates
    ///   - cartItem: item for quantity updates
    ///   - quantity: updated quantity
    /// - Returns: success/failure
    class func updateQuantity(cart: TMCart, cartItem: TMCartItem, quantity: Int)-> Promise<Bool> {
        
        // Params for request
        let itemForCart = cartItem.transformForCartJSONWithQuantity(quantity)
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.patch, path: "carts/\(cart.id!)", parameters: itemForCart).then { response-> Promise<TMCart?> in
            
            return TMCoreDataManager.insertASync(Into<TMCart>(), source: response)
            }.then { response-> Bool in
        
                return true
        }
    }
    
    /// Set address for cart
    ///
    /// - Parameters:
    ///   - cart: cart for updates
    ///   - address: new address
    /// - Returns: updated cart
    class func setAddress(cart: TMCart?, address: TMContactAddress)-> Promise<TMCart?> {
        
        // Safety check
        guard let cart = cart else {
            return Promise<TMCart?>(value: nil)
        }
        
        // Params for request
        var addressDict = address.getDictFromObject()
        
        var source = ""
        var sourceID = ""
        
        if let contact = address.contact {
            
            source = "contact"
            sourceID = contact.id
        }
        else if let user = address.user {
            
            source = "user"
            sourceID = user.id
        }
        
        // Updated params
        addressDict["source"] = source
        addressDict["source_id"] = sourceID
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "carts/\(cart.id!)/address", parameters: addressDict).then { response-> Promise<TMCart?> in
            
            return Promise { fulfill, reject in
                
                TMCoreDataManager.defaultStack.beginAsynchronous { transaction in
                 
                    let cart = transaction.edit(cart)
                    let address = transaction.edit(address)
                    
                    cart?.address = address
                    transaction.commit()
                    
                    fulfill(cart)
                }
            }
        }
    }
    
    /// Set payment for cart
    ///
    /// - Parameters:
    ///   - cart: cart for updates
    ///   - card: new credit card
    /// - Returns: updated cart
    class func setPayment(cart: TMCart?, card: TMPayment?)-> Promise<TMCart?> {
        
        // Safety check
        guard let cart = cart, let card = card else {
            return Promise<TMCart?>(value: nil)
        }
        
        // Params for request
        let paymentDict = ["source": "card", "source_id": card.id!]
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "carts/\(cart.id!)/payment", parameters: paymentDict).then { response-> Promise<TMPayment?> in
            
            return TMCoreDataManager.fetchExisting(card)
            }.then { payment-> Promise<TMCart?> in
                
                return Promise { fulfill, reject in
                    
                    TMCoreDataManager.defaultStack.beginAsynchronous { transaction in
                        
                        let cart = transaction.edit(cart)
                        let payment = transaction.edit(payment)
                        
                        cart?.payment = payment
                        transaction.commit()
                        
                        fulfill(cart)
                    }
                }
        }
    }
    
    /// Set label for cart
    ///
    /// - Parameters:
    ///   - cart: cart for updates
    ///   - labelParams: new label
    /// - Returns: updated cart
    class func setLabel(cart: TMCart?, labelParams: [String: Any])-> Promise<TMCart?> {
        
        // Safety check
        guard let cart = cart else {
            return Promise<TMCart?>(value: nil)
        }
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "carts/\(cart.id!)/label", parameters: labelParams).then { response-> Promise<TMCartLabel?> in
            
            return TMCoreDataManager.insertASync(Into<TMCartLabel>(), source: response)
            }.then { response-> Promise<TMCartLabel?> in
                
                return TMCoreDataManager.fetchExisting(response)
            }.then { label-> Promise<TMCart?> in
                
                return Promise { fulfill, reject in
                    
                    TMCoreDataManager.defaultStack.beginAsynchronous { transaction in
                        
                        let cart = transaction.edit(cart)
                        let label = transaction.edit(label)
                        
                        cart?.label = label
                        transaction.commit()
                        
                        fulfill(cart)
                    }
                }
        }
    }
    
    /// Update shipping type for cart
    ///
    /// - Parameters:
    ///   - cart: cart for updates
    ///   - shippingTypeID: new shipping type
    /// - Returns: updated cart
    class func setShippingTypeID(cart: TMCart, shippingType: TMShippingType?)-> Promise<TMCart?> {
        
        // Safety check
        guard let cartID = cart.id, let shippingType = shippingType else {
            return Promise<TMCart?>(value: nil)
        }
        
        // Params for request
        let params = ["shipping_type_id": shippingType.id!]
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "carts/\(cartID)/shipping", parameters: params).then { response-> Promise<TMCart?> in
            
            return Promise { fulfill, reject in
                
                TMCoreDataManager.defaultStack.beginAsynchronous { transaction in
                    
                    let cart = transaction.edit(cart)
                    let shippingType = transaction.edit(shippingType)
                    
                    cart?.orderType = shippingType
                    transaction.commit()
                    
                    fulfill(cart)
                }
            }
        }
    }
    
    /// Fetch cart details from server
    ///
    /// - Parameter cartID: cart if
    /// - Returns: cart object
    class func fetchCart(request: TMRequest?)-> Promise<TMCart?> {
        
        // Safety check
        guard let _cartID = request?.cartID else {
            return Promise<TMCart?>(value: nil)
        }
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "carts/\(_cartID)").then { response-> Promise<TMCart?> in
            
            return TMCoreDataManager.insertASync(Into<TMCart>(), source: response)
            }.then { response-> Promise<TMCart?> in
                
                return Promise { fulfill, reject in
                    
                    TMCoreDataManager.defaultStack.beginAsynchronous { transaction in
                     
                        let request = transaction.edit(request)
                        let cart = transaction.edit(response)
                        
                        if let cart = cart {
                            
                            request?.cart = cart
                        }
                        
                        transaction.commit()
                        
                        fulfill(cart)
                    }
                }
        }
    }
    
    /// Start cart checkout
    ///
    /// - Parameter cart: cart for checkout
    /// - Returns: updated cart
    class func checkout(cart: TMCart)-> Promise<TMCart?> {
        
        // Safety check
        guard let cartID = cart.id else {
            return Promise<TMCart?>(value: nil)
        }
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "carts/\(cartID)/checkout").then { response-> Promise<TMCart?> in
            
            return TMCoreDataManager.insertASync(Into<TMCart>(), source: response)
            }.then { response-> Promise<TMCart?> in
                
                return TMCoreDataManager.fetchExisting(response)
        }
    }
    
    /// Add item to cart
    ///
    /// - Parameters:
    ///   - cartID: cart to update
    ///   - item: item to add
    /// - Returns: updated cart
    class func addItem(cart: TMCart, item: TMItem)-> Promise<TMCart?> {
        
        // Params for request
        let itemForCart = item.toJSON(quantity: 1)
        
        // networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "carts/\(cart.id!)/items", parameters: itemForCart).then { response-> Promise<TMCartItem?> in
            
            return TMCoreDataManager.insertASync(Into<TMCartItem>(), source: response)
            }.then { response-> Promise<TMCart?> in
                
                return Promise { fulfill, reject in
                
                    TMCoreDataManager.defaultStack.beginAsynchronous { transaction in
                     
                        let cart = transaction.edit(cart)
                        let cartItem = transaction.edit(response)
                        
                        if let cartItem = cartItem {
                            
                            cart?.addItemsObject(cartItem)
                        }
                        
                        transaction.commit()
                        
                        fulfill(cart)
                    }
                }
        }
    }
}
