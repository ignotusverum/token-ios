//
//  TMContact.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright Â© 2016 Human Ventures Co. All rights reserved.
//

import CoreStore
import SwiftyJSON
import PromiseKit
import Contacts

let TMContactRefreshTimeInterval: Int = 60 * 60 * 1 // 1 hr

/// Struct that represent User JSON keys
public struct TMContactJSON {
    
    static let userID = "userID"
    
    static let firstName = "first_name"
    static let lastName = "last_name"
    
    static let note = "note"
    static let birthday = "birthday"
    static let addresses = "addresses"
    
    static let identifier = "contacts_identifier"    
}

@objc(TMContact)
open class TMContact: _TMContact {

    var firstNameDisplay: String? {
        
        return self.firstName
    }
    
    var lastNameDisplay: String? {
        
        return self.lastName
    }
    
    // Address Book Object
    var contactAddressBook: CNContact? {
        didSet {
            
            self.getImage({ (image) in
                
                if let image = image {
                    self.localContactImage = image
                }
                }) { }
        }
    }
    
    var localContactImage: UIImage?
    
    // Addresses Array
    var addressesArray: [TMContactAddress] {
        return self.addresses.array as? [TMContactAddress] ?? []
    }
    
    // Utilities
    
    class func mergeContacts(_ contacts: [TMContact], addressBookContacts: [CNContact])-> Promise<(mergedContacts: [TMContact], cleanedABContacts: [CNContact])> {
        
        return Promise { fulfill, reject in
         
            var contactsMerged = addressBookContacts
            
            TMCoreDataManager.defaultStack.beginAsynchronous { transaction in
                
                for contact in contacts {
                    for abContact in addressBookContacts {
                        
                        if (contact.firstName == abContact.givenName && contact.lastName == abContact.familyName) || (contact.lastName == nil && contact.firstName == abContact.givenName) || contact.identifier == abContact.identifier {
                            
                            contact.identifier = abContact.identifier
                            contact.contactAddressBook = abContact
                            
                            contactsMerged.removeFirst(abContact)
                        }
                    }
                }
                
                transaction.commit()
                
                fulfill((mergedContacts: contacts, cleanedABContacts:contactsMerged))
            }
        }
    }
    
    // Getting image
    func getImage(_ success:@escaping (_ image: UIImage?)-> Void, failure: ()-> Void) {
        
        guard let identifier = self.identifier else {
            
            failure()
            return
        }
        
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            let contactStore = CNContactStore()
            
            do {
                let contact = try contactStore.unifiedContact(withIdentifier: identifier, keysToFetch: [CNContactImageDataKey as CNKeyDescriptor])
                
                if let imageData = contact.imageData {
                    localContactImage = UIImage(data: imageData)
                    success(localContactImage)
                } else {
                    success(nil)
                }
                
            } catch let error {
                print(error.localizedDescription)
                success(nil)
            }
        } else {
            success(nil)
        }
    }
    
    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {

        try super.updateModel(with: source, transaction: transaction)
        
        // First Name
        firstName = source[TMContactJSON.firstName].string
        
        // Last Name
        lastName = source[TMContactJSON.lastName].string
        
        // Fetch addresses
        note = source[TMContactJSON.note].string
        
        // Birthday
        birthday = source[TMContactJSON.birthday].dateTime
        
        // User ID
        userID = source[TMContactJSON.userID].string
        
        // Address book ID
        let recordNumber = source[TMContactJSON.identifier].string ?? "0"
        identifier = recordNumber
        
        // Addresses
        let addressesJSONArray = source[TMContactJSON.addresses].array ?? []
        let tempAddresses = try transaction.importUniqueObjects(Into<TMContactAddress>(), sourceArray: addressesJSONArray)
        addAddresses(NSOrderedSet(array: tempAddresses))
    }
}
