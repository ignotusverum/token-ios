//
//  TMUserAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/26/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Alamofire
import PromiseKit
import SwiftyJSON

import CoreStore

/// Validation enums
///
/// - avaliable: request successful
/// - unavaliable: request failed
enum ValidationCheck {
    
    case avaliable
    case unavaliable
}

class TMUserAdapter: TMSynchronizerAdapter {

    // MARK: - Requests
    /// Checks if emails is already taken
    ///
    /// - Parameter userName: email
    /// - Returns: validation result
    class func usernameCheck(_ userName: String?) -> Promise<ValidationCheck> {
        
        // Safety check
        guard let userName = userName, !userName.containsWhitespace else {
            
            return Promise(value: .unavaliable)
        }
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "register/availability", parameters: ["userName": userName]).then { resultJSON -> ValidationCheck in
            
            // Pulling result from json
            if let resultBool = resultJSON["available"].bool {
                
                if resultBool {
                
                    return .avaliable
                }
                else {
                    
                    return .unavaliable
                }
            }
            
            return .unavaliable
        }
    }
    
    /// Delete user address
    ///
    /// - Parameter address: address object
    /// - Returns: success/failure
    class func deleteAddress(_ address: TMContactAddress)-> Promise<Bool> {

        // Safety check
        guard let addressID = address.id else {
            return Promise(value: false)
        }
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.delete, path: "addresses/\(addressID)").then { resultJSON-> Promise<Bool> in
         
            return TMCoreDataManager.deleteASync([address])
            }.then { result-> Bool in
                
                return result
        }
    }
    
    /// Updating current user
    ///
    /// - Parameters:
    ///   - dict: temp params for user
    class func update(_ dict: [String: Any]?)-> Promise<TMUser?> {
    
        // Safety check
        guard let dict = dict else {
            return Promise(value: nil)
        }
    
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.patch, path: "me", parameters: dict).then { responseJSON-> Promise<TMUser?> in
            
            return TMCoreDataManager.insertSync(Into<TMUser>(), source: responseJSON)
            }.then { user-> TMUser? in
                
                let config = TMConsumerConfig.shared
                config.currentUser = user
                
                return user
        }
    }
    
    /// Fetch address list from server
    ///
    /// - Returns: Array of address objects
    class func fetchAddressList()-> Promise<[TMContactAddress]> {
        
        let netman = TMNetworkingManager.shared
        
        // Networking call
        return netman.request(.get, path: "addresses").then { responseJSON-> Promise<[TMContactAddress]> in
            
            guard let jsonArray = responseJSON.array else {
                return Promise(value: [TMContactAddress]())
            }
            
            removeOldAddresses(jsonArray)
            
            return TMCoreDataManager.insertASync(Into<TMContactAddress>(), source: jsonArray)
            }.then { insertResult-> Promise<[TMContactAddress]> in
                
                // Creating relation between address - user
                return Promise { fulfill, reject in
                 
                    TMCoreDataManager.defaultStack.beginAsynchronous { transaction in
                        
                        let config = TMConsumerConfig.shared
                        let userObject = config.currentUser
                        
                        guard var user = userObject else {
                            fulfill(insertResult)
                            return
                        }

                        user = transaction.edit(user)!
                        let addresses = insertResult.flatMap { transaction.edit($0) }
                        
                        user.addAddresses(NSOrderedSet(array: addresses))
                        
                        _ = transaction.commit()
                     
                        fulfill(insertResult)
                    }
                }
        }
    }
    
    /// Remove old addresses from db
    ///
    /// - Parameter addresses: addressess from server
    class func removeOldAddresses(_ addresses: [JSON]) {
        
        let addressesIDs = addresses.flatMap { $0["id"].string }
        
        let currentUser = TMConsumerConfig.shared.currentUser
        
        if let currentUser = currentUser {
            
            TMCoreDataManager.defaultStack.beginAsynchronous { transaction-> Void in
                
                transaction.deleteAll(From<TMPayment>(), Where("NOT (%K IN %@) AND %K.%K == %@", TMModelAttributes.id.rawValue, addressesIDs, TMContactAddressRelationships.user.rawValue, TMModelAttributes.id.rawValue, currentUser.id))
                transaction.commit()
            }
        }
    }
    
    /// Remove old cards from database
    ///
    /// - Parameter cards: cards from server
    class func removeOldCards(_ cards: [TMPayment]) {
        
        let cardIDs = cards.flatMap { $0.id }
        
        TMCoreDataManager.defaultStack.beginAsynchronous { transaction-> Void in
            
            transaction.deleteAll(From<TMPayment>(), Where("NOT (%K IN %@)", TMModelAttributes.id.rawValue, cardIDs))
            transaction.commit()
        }
    }
    
    /// Updates addreess
    ///
    /// - Parameters:
    ///   - addressID: addressID
    ///   - params: parameters for update
    /// - Returns: returns updated address
    class func updateAddress(_ addressID: String, params: [String: Any])-> Promise<TMContactAddress?> {

        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.patch, path: "addresses/\(addressID)", parameters: params).then { response-> Promise<TMContactAddress?> in
            
            return TMCoreDataManager.insertASync(Into<TMContactAddress>(), source: response)
            }.then { insertObject-> TMContactAddress? in
                
                return insertObject
        }
    }
    
    /// Add Address
    ///
    /// - Parameter params: parameters for address
    /// - Returns: address object
    class func addAddress(_ params: [String: Any])-> Promise<Bool> {
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "addresses", parameters: params).then { responseJSON-> Bool in
            
            return true
        }
    }
    
    /// Fethes current user from server
    ///
    /// - Returns: user object
    class func fetchMe()-> Promise<TMUser?> {
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "me").then { responseJSON-> Promise<TMUser?> in

            // Save/Update User object
            return TMCoreDataManager.insertASync(Into<TMUser>(), source: responseJSON)
            }.then { user-> Promise<TMUser?> in
                
                // Fetch data for user from db
                return TMCoreDataManager.fetchExisting(user)
            }.then { user-> TMUser? in
                
                // Save User object to config
                let config = TMConsumerConfig.shared
                config.currentUser = user
                
                return user
        }
    }
    
    // MARK: - Phone validation - registration
    
    /// Reset password call
    ///
    /// - Parameters:
    ///   - phoneToken: phone validation number (4 digits)
    ///   - phoneNumber: phone number for reset
    ///   - email: email for reset
    ///   - newPassword: new password
    /// - Returns: success/failure
    class func resetPassword(_ phoneToken: String, phoneNumber: String, email: String, newPassword: String)-> Promise<Bool> {
        
        // Request params
        let requestParams = ["email": email, "phone_number": phoneNumber, "verification_code": phoneToken, "password": newPassword]
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "password/confirm", parameters: requestParams).then { responseJSON-> Bool in
            
            return true
        }
    }
    
    /// Get phone token from twillio - password reset
    ///
    /// - Parameter phoneString: phone number
    /// - Returns: success/failure
    class func generatePhoneToken(_ phoneString: String)-> Promise<Bool?> {
        
        // Request params
        let requestParams = ["phone_number": phoneString]
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "password/reset", parameters: requestParams).then { responseJSON-> Bool in
            
            return true
        }
    }
    
    /// Get phone token twillio - registration
    ///
    /// - Parameter phoneString: phone number
    /// - Returns: success/failure
    class func generatePhoneValidation(_ phoneString: String)-> Promise<Bool?> {
        
        // Request params
        let requestParams = ["phone_number": phoneString]
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "verification/start", parameters: requestParams).then { responseJSON-> Bool in
            
            return true
        }
    }
    
    /// Register new user
    ///
    /// - Returns: new user json
    class func register(params: [String: Any]?) -> Promise<JSON?> {
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "register", parameters: params).then { responseJSON -> JSON? in
            
            if let accessToken = responseJSON["access_token"].string {
                
                netman.accessToken = accessToken
                
                netman.postLoginNotificaitonWithSuccess(true)
            }
            
            return responseJSON
            
        }
    }
    
    /// Validate twillio token against phone number
    ///
    /// - Parameters:
    ///   - phoneToken: twillio token (4 digits)
    ///   - phoneNumber: phone number
    /// - Returns: success/failure
    class func validateToken(_ phoneToken: String, phoneNumber: String)-> Promise<Bool> {
        
        return Promise { fulfill, reject in
            
            // Request params
            let requestParams = ["verification_code": phoneToken, "phone_number": phoneNumber]
            
            // Networking Call
            let netman = TMNetworkingManager.shared
            netman.request(.post, path: "verification/check", parameters: requestParams).then { responseJSON-> Void in
                
                // Check for error message - should change later from server side
                guard let success = responseJSON["success"].bool, success == true else {
                
                    let message = responseJSON["message"].string ?? "Whoops, something went wrong, please try again."
                    let updatedError = NSError(domain: hostName, code: 500, userInfo: [NSLocalizedDescriptionKey : message])
                    
                    reject(updatedError)
                    return
                }
                
                fulfill(true)
                
                }.catch { error in
                    
                    reject(error)
            }
        }
    }
}
