//
//  TMContactAddressAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/30/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import CoreStore
import PromiseKit

class TMContactAddressAdapter: TMSynchronizerAdapter {

    override func synchronizeData() {
        
        TMUserAdapter.fetchAddressList().then { response-> Void in
            
            super.synchronizeData()
            }.catch { error-> Void in
                
                super.synchronizeData()
        }
    }
    
    /// Update contact address
    ///
    /// - Parameters:
    ///   - address: address object for updates
    ///   - contact: contact related to address
    ///   - params: params for update
    /// - Returns: updated contact address
    class func update(_ address: TMContactAddress, contact: TMContact, params: [String: Any])-> Promise<Bool> {
        
        let netman = TMNetworkingManager.shared
        
        return netman.request(.patch, path: "contacts/\(contact.id!)/addresses/\(address.id!)", parameters: params).then { response-> Promise<TMContactAddress?> in

            return TMCoreDataManager.insertASync(Into<TMContactAddress>(), source: response)
            }.then { response-> Bool in
                
                return true
        }
    }
}
