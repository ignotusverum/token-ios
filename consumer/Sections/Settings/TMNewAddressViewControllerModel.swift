//
//  TMNewAddressViewControllerModel.swift
//  consumer
//
//  Created by Gregory Sapienza on 1/12/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation
import PromiseKit

protocol TMNewAddressViewControllerModelProtocol {
    
    /// Checks to see if address entries can be validated.
    ///
    /// - Returns: Error if an entry is not validated. Nil if everything is successful.
    func checkForValidationError() -> NSError?
    
    /// Presents a notification based on a new status.
    ///
    /// - Parameter status: String to present in notification
    func showNotificationStatus(status: String)
    
    /// When address has been saved for the current user.
    func addressSavedForCurrentUser()
    
    /// When address has been saved for a contact.
    func addressSavedForContact()
}

class TMNewAddressViewControllerModel {
    
    //MARK: - Public iVars
    
    /// Existing address for contact.
    var address: TMContactAddress?
    
    /// Dictionary for request.
    var paramsForRequest: [String: Any]?
    
    /// Model delegate to communicate any changes.
    var delegate :TMNewAddressViewControllerModelProtocol?
    
    //MARK: - Public
    
    /// Submits data for current user's address.
    ///
    /// - Returns: Promise for user based on submission.
    func promiseCheckAndSubmitForCurrentUser() -> Promise<TMContactAddress?> {
        return Promise { fulfill, reject in
          
            if let resultError = delegate?.checkForValidationError() {
                if let errorMessage = AddressField.errorMessage(errorCode: resultError.code) {
                    delegate?.showNotificationStatus(status: errorMessage)
                }
                
                reject(TMError)
            }
            
            guard var paramsForRequest = self.paramsForRequest else {
                print("ParamsForRequest is nil.")
                return
            }
            
            if let address = self.address, let modelObjectID = address.id { //If there is an existing address.
                
                paramsForRequest["id"] = modelObjectID
                
                TMUserAdapter.updateAddress(modelObjectID, params: paramsForRequest).then { result -> Void in
                    self.delegate?.addressSavedForCurrentUser()
                    fulfill(result)
                    }.catch { error in
                        
                        reject(error)
                }
                
            } else { //With no existing address.
                
                TMUserAdapter.addAddress(paramsForRequest).then { result -> Promise<[TMContactAddress]> in
                    
                    return TMUserAdapter.fetchAddressList()
                    }.then { result-> Void in
                    
                        self.delegate?.addressSavedForCurrentUser()
                        fulfill(nil)
                    }.catch { error in
                        
                        reject(error)
                }
            }
        }
    }
    
    /// Submits data for a contacts address.
    ///
    /// - Returns: Promise for contact based on submission.
    func promiseCheckAndSubmitForContact(contact: TMContact) -> Promise<TMContactAddress?> {
        return Promise { fulfill, reject in
            
            if let resultError = delegate?.checkForValidationError() {
                if let errorMessage = AddressField.errorMessage(errorCode: resultError.code) {
                    delegate?.showNotificationStatus(status: errorMessage)
                }
                
                reject(TMError)
            }
            
            guard let paramsForRequest = self.paramsForRequest else {
                print("ParamsForRequest is nil.")
                return
            }
            
            if let address = self.address { //If there is an existing address.
                
                TMContactAddressAdapter.update(address, contact: contact, params: paramsForRequest).then { result -> Promise<TMContact?> in
                    
                    return TMContactsAdapter.fetch(contactID: contact.id)
                    }.then { result -> Void in
                        self.delegate?.addressSavedForContact()
                        fulfill(nil)
                    }.catch { error in
                        reject(error)
                }
                
            } else { //With no existing address.
                
                TMContactsAdapter.addAddress(contact, params: paramsForRequest).then { result -> Void in
                    
                    TMContactsAdapter.fetch(contactID: contact.id).then { contact -> Void in
                        self.delegate?.addressSavedForContact()
                        fulfill(result)
                        }.catch { error in
                            print(error)
                    }
                    
                    }.catch { error in
                        
                        reject(error)
                }
            }
        }
    }
}
