//
//  TMContactsAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 7/7/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON
import PromiseKit
import Contacts

class TMContactsAdapter: TMSynchronizerAdapter {
    
    /// Contacts synchronized
    override func synchronizeData() {
        
        TMContactsAdapter.fetchList().then { tokenContacts -> Promise<(tokenContacts: [TMContact]?, localContacts: [CNContact]?)> in
            
            return TMAddressBookManager.loadAndMergeContactsSynch(tokenContacts)
            }.then { tokenContacts, localContacts-> Void in
            
                let contactManager = TMAddressBookManager.sharedManager
                
                if let tokenContacts = tokenContacts {
                    
                    contactManager.tokenContacts = tokenContacts
                }
                
                if let localContacts = localContacts {
                    
                    contactManager.localContacts = localContacts
                }
                
                super.synchronizeData()
            }.catch { error in
            
                super.synchronizeData()
        }
    }
    
    // Update contact with address
    class func addAddress(_ contact: TMContact, params: [String: Any])-> Promise<TMContactAddress?> {
        
        // Safety check
        guard let contactID = contact.id else {
            
            return Promise(value: nil)
        }
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "contacts/\(contactID)/addresses", parameters: params).then { responseJSON-> Promise<TMContactAddress?> in
         
            return TMCoreDataManager.insertASync(Into<TMContactAddress>(), source: responseJSON)
            }.then { insertResponse-> Promise<TMContactAddress?> in
                
                return TMCoreDataManager.fetchExisting(insertResponse)
            }.then { fetchedObject-> TMContactAddress? in
                
                return fetchedObject
        }
    }
    
    /// Fetching contact list
    ///
    /// - Returns: array of contact
    class func fetchList()-> Promise<[TMContact]> {
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "contacts").then { response-> Promise<[TMContact]> in
            
            guard let responseArray = response.array else {
                return Promise(value:[])
            }
            
            removeOldContacts(responseArray)
            
            return TMCoreDataManager.insertASync(Into<TMContact>(), source: responseArray)
            }.then { response-> Promise<[TMContact]> in
                
                return TMCoreDataManager.fetchExisting(response)
        }
    }
    
    /// Fetch contact with id
    ///
    /// - Parameter contactID: contact id
    /// - Returns: contact object
    class func fetch(contactID: String)-> Promise<TMContact?> {
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "contacts/\(contactID)").then { response-> Promise<TMContact?> in
    
            return TMCoreDataManager.insertASync(Into<TMContact>(), source: response)
            }.then { response-> Promise<TMContact?> in
                
                return TMCoreDataManager.fetchExisting(response)
        }
    }
    
    /// Create contact from local contact
    ///
    /// - Parameter contact: local contact object
    /// - Returns: database - token contact
    class func create(contactParams: [String: Any])-> Promise<TMContact?> {
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "contacts", parameters: contactParams).then { result -> Promise<TMContact?> in
            
            // Safety check
            guard let modelID = result["id"].string else {
                return Promise(value: nil)
            }
            
            return TMContactsAdapter.fetch(contactID: modelID)
            }.then { responseContact-> Promise<TMContact?> in

                return Promise { fulfill, reject in
                    
                    self.fetchList().then { response-> Promise<(tokenContacts: [TMContact]?, localContacts: [CNContact]?)> in
                        
                        return TMAddressBookManager.loadAndMergeContactsSynch(response)
                        }.then { (tokenContacts: [TMContact]?, localContacts: [CNContact]?)-> Void in
                            
                            let contactManager = TMAddressBookManager.sharedManager
                            
                            if let tokenContacts = tokenContacts {
                                
                                contactManager.tokenContacts = tokenContacts
                            }
                            
                            if let localContacts = localContacts {
                                
                                contactManager.localContacts = localContacts
                            }
                            
                            fulfill(responseContact)
                        }.catch { error in
                            
                            fulfill(responseContact)
                    }
                }
        }
    }
    
    /// Remove old contacts from database
    ///
    /// - Parameter cards: cards from server
    class func removeOldContacts(_ contacts: [JSON]) {
        
        let contacts = contacts.flatMap { $0["id"].string }
        
        TMCoreDataManager.defaultStack.beginAsynchronous { transaction-> Void in
            
            transaction.deleteAll(From<TMContact>(), Where("NOT (%K IN %@)", TMModelAttributes.id.rawValue, contacts))
            transaction.commit()
        }
    }
}
