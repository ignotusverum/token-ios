//
//  TMAddressBookManager.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 7/28/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Contacts
import PromiseKit

class TMAddressBookManager: NSObject {
    
    // Shared manager
    static let sharedManager = TMAddressBookManager()
    
    // Token Contacts
    var tokenContacts = [TMContact]()
    
    // Local Contacts
    var localContacts = [CNContact]()
    
    // Load contacts
    class func loadAndMergeContactsSynch(_ contacts: [TMContact]?)-> Promise<(tokenContacts: [TMContact]?, localContacts: [CNContact]?)> {
        
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else {
            
            return Promise(value: (tokenContacts: contacts, localContacts: []))
        }
        
        return loadAndMergeContacts(contacts)
    }
    
    class func loadAndMergeContacts(_ contacts: [TMContact]?)-> Promise<(tokenContacts: [TMContact]?, localContacts: [CNContact]?)> {
    
        guard let tokenContacts = contacts else {
            return Promise(value: (tokenContacts: [], localContacts: []))
        }
    
        var abContacts: [CNContact] = []

        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            let contactStore = CNContactStore()
            
            let contactKeys =  [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactIdentifierKey, CNContactImageDataKey, CNContactThumbnailImageDataKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactJobTitleKey, CNContactOrganizationNameKey, CNContactBirthdayKey, CNContactSocialProfilesKey]
            let contactFetchRequest = CNContactFetchRequest(keysToFetch: contactKeys as [CNKeyDescriptor])
            contactFetchRequest.sortOrder = .givenName
            
            do {
                try contactStore.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact: CNContact, error: UnsafeMutablePointer<ObjCBool>) in
                    if contact.givenName.length > 0 || contact.familyName.length > 0 {
                        abContacts.append(contact)
                    }
                })
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        return TMContact.mergeContacts(tokenContacts, addressBookContacts: abContacts).then { tokenContacts, addressBookContacts-> (tokenContacts: [TMContact]?, localContacts: [CNContact]?) in
            
            let sortedResultlocalContacts = addressBookContacts.sorted(by: { (contact1, contact2) -> Bool in
                
                let name1 = contact1.givenName.lowercased()
                let name2 = contact2.givenName.lowercased()
                
                return name1 < name2
            })
            
            let sortedResultOfTokenContacts = tokenContacts.sorted(by: { (contact1, contact2) -> Bool in
                
                let name1 = contact1.firstName?.lowercased() ?? "z"
                let name2 = contact2.firstName?.lowercased() ?? "z"
                
                return name1 < name2
            })
            
            return (tokenContacts: sortedResultOfTokenContacts, localContacts: sortedResultlocalContacts)
        }
    }
}
