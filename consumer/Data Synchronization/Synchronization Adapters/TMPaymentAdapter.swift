//
//  TMPaymentAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/17/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Stripe
import CoreStore
import PromiseKit
import SwiftyJSON

class TMPaymentAdapter: TMSynchronizerAdapter {

    /// Adapter synchronized
    override func synchronizeData() {
        
        TMPaymentAdapter.fetchList().then { response-> Void in
            
            super.synchronizeData()
            }.catch { error-> Void in
                
                super.synchronizeData()
        }
    }
    
    /// Create Credit Card with parameters
    ///
    /// - Parameters:
    ///   - number: card number
    ///   - expirationMo: card expiration month
    ///   - expirationYear: card expiration year
    ///   - cvcCode: cvc code
    ///   - zipCode: zip - optional from server
    ///   - name: name on card
    /// - Returns: payment object
    class func addCardWithNumber(_ number: String, expirationMo: UInt, expirationYear: UInt, cvcCode: String, zipCode: String, name: String)-> Promise<TMPayment?> {
        
        let params = STPCardParams()
        params.number = number
        params.expMonth = expirationMo
        params.expYear = expirationYear
        params.cvc = cvcCode
        params.addressZip = zipCode
        params.name = name
        
        return TMPaymentAdapter.create(params)
    }
    
    /// Create credit card
    ///
    /// - Parameter cardParams: stripe params
    /// - Returns: credit card object
    class func create(_ cardParams: STPCardParams)-> Promise<TMPayment?> {
    
        return Promise { fulfill, reject in
         
            // Stripe call
            STPAPIClient.shared().createToken(withCard: cardParams) { (token, error) -> Void in
                
                if let error = error {
                    // error handle
                    reject(error)
                }
                else {
                    
                    let requestParams = ["token" : token!.tokenId]
                    
                    // networking call
                    let netman = TMNetworkingManager.shared
                    netman.request(.post, path: "cards", parameters: requestParams).then { responseJSON-> Promise<TMPayment?> in
                        
                        return TMCoreDataManager.insertSync(Into<TMPayment>(), source: responseJSON)
                        }.then { payment-> Promise<TMPayment?> in
                            
                            // Creating relation between user and payments
                            return Promise { fulfill, reject in
                                
                                TMCoreDataManager.defaultStack.beginAsynchronous { transition in
                                    
                                    let config = TMConsumerConfig.shared
                                    let userObject = config.currentUser
                                    
                                    guard var user = userObject else {
                                        fulfill(payment)
                                        return
                                    }
                                    
                                    user = transition.edit(user)!
                                    let payment = transition.edit(payment)
                                    
                                    if let payment = payment {
                                        user.addCardsObject(payment)
                                    }
                                    
                                    _ = transition.commit()
                                    
                                    fulfill(payment)
                                }
                            }
                        }.then { payment-> Void in
                            
                            fulfill(payment)
                            
                        }.catch { error-> Void in
                            
                            reject(error)
                    }
                }
            }
        }
    }
    
    /// Fetches list of cards from server
    ///
    /// - Returns: array of cards
    class func fetchList()-> Promise<[TMPayment]> {
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "cards").then { responseJSON-> Promise<[JSON]> in
            
            let sourceArray = responseJSON.array ?? [JSON]()

            // Remove old cards from database
            return self.removeOldCards(sourceArray)
            }.then { sourceArray-> Promise<[TMPayment]> in
        
                return TMCoreDataManager.insertASync(Into<TMPayment>(), source: sourceArray)
            }.then { paymentArray-> Promise<[TMPayment]> in

                // Creating relation between user and payments
                return Promise { fulfill, reject in
                    
                    TMCoreDataManager.defaultStack.beginAsynchronous { transition in
                        
                        let config = TMConsumerConfig.shared
                        let userObject = config.currentUser
                        
                        guard var user = userObject else {
                            fulfill(paymentArray)
                            transition.commit()
                            return
                        }
                        
                        user = transition.edit(user)!
                        let payments = paymentArray.flatMap { transition.edit($0) }
                        
                        user.addCards(NSOrderedSet(array: payments))
                        
                        transition.commit()
                        
                        fulfill(paymentArray)
                    }
                }
        }
    }
    
    /// Delete user payment
    ///
    /// - Parameter creditCard: creditCard object
    /// - Returns: success/failure
    class func deletePayment(_ payment: TMPayment)-> Promise<Bool> {
        
        // Safety check
        guard let cardID = payment.id else {
            return Promise(value: false)
        }
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.delete, path: "cards/\(cardID)").then { responseJSON-> Promise<Bool> in
            
            return TMCoreDataManager.deleteASync([payment])
            }.then { result-> Bool in
                
                return result
        }
    }

    /// Remove old cards from database
    ///
    /// - Parameter cards: cards from server
    class func removeOldCards(_ cards: [JSON])-> Promise<[JSON]> {
        
        return Promise { fulfill, reject in
            
            let cardsIDs = cards.flatMap { $0["id"].string }
            
            TMCoreDataManager.defaultStack.beginAsynchronous { transaction-> Void in
                
                transaction.deleteAll(From<TMPayment>(), Where("NOT (%K IN %@)", TMModelAttributes.id.rawValue, cardsIDs))
                transaction.commit { result in
                    fulfill(cards)
                }
            }
        }
    }
}
