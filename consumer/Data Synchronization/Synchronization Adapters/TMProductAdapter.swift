//
//  TMProductAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/26/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON
import PromiseKit

class TMProductAdapter: TMSynchronizerAdapter {

    /// Fetch product with time check
    /// 1hr
    /// - Parameters:
    ///   - objectID: product id to fetch
    ///   - context: context to save
    /// - Returns: product object
    /// - Throws: can throw if not in context
    class func fetch(productID: String) -> Promise<TMProduct?> {
        
        let product = TMCoreDataManager.defaultStack.fetchOne(From<TMModel>(),
                                        Where("\(TMModelAttributes.id.rawValue) == %@", productID)) as? TMProduct
        
        var databaseCopyIfFresh = false
        
        if product?.localUpdatedAt != nil && product?.id != nil {
            let tmpInterval = product?.localUpdatedAt?.timeIntervalSinceNow
            
            if tmpInterval != nil {
                databaseCopyIfFresh = Int(tmpInterval!) > -1 * TMContactRefreshTimeInterval
            }
        }
        
        if product != nil && databaseCopyIfFresh {
            
            return Promise(value: product)
        }
        else {
            
            return TMProductAdapter.fetchFromServer(productID: productID)
        }
    }
    
    /// Fetch product with custom context
    ///
    /// - Parameters:
    ///   - productID: product id to fetch
    ///   - context: context for saving
    /// - Returns: updated product
    class func fetchFromServer(productID: String)-> Promise<TMProduct?> {
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "products/\(productID)").then { response-> Promise<TMProduct?> in
            
            return TMCoreDataManager.insertASync(Into<TMProduct>(), source: response)
            }.then { response-> Promise<TMProduct?> in
                
                return TMCoreDataManager.fetchExisting(response)
            }.then { response-> Promise<TMProduct?> in
                
                // Create relation between 
                // Cart item -> Product
                return Promise { fulfill, reject in
                    
                    TMCoreDataManager.defaultStack.beginAsynchronous { transaction in
                        
                        var cartItems = transaction.fetchAll(From<TMCartItem>(), Where("\(TMCartItemAttributes.productID.rawValue) == %@", response?.id ?? "")) ?? []
                        
                        cartItems = cartItems.flatMap { transaction.edit($0) }
                        
                        let product = transaction.edit(response)
                        product?.addCartItem(NSOrderedSet(array: cartItems))
                        
                        _ = transaction.commit()
                        
                        fulfill(response)
                    }
                }
        }
    }
}
