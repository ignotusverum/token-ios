//
//  TMConversationAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/5/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import SwiftyJSON
import PromiseKit
import EZSwiftExtensions
import JDStatusBarNotification

class TMConversationAdapter: TMSynchronizerAdapter {
    
    /// Conversatoin synchronized
    override func synchronizeData() {
        
        let manager = TMConversationManager.shared
        // Check if manager exists and not expired
        if manager == nil {
            
            // Parameters for request
            let config = TMConsumerConfig.shared
            
            // Required params for conversation
            let deviceID = UIDevice.idForVendor()
            let userID = config.currentUser?.id
            
            // Safety check
            if let deviceID = deviceID, let userID = userID {
                // Getting conversation information
                TMConversationAdapter.fetchConversation(identity: userID, deviceID: deviceID).then { (token, identity)-> Promise<TwilioChatClient?> in
                    
                    let conversationManger = TMConversationManager(accessToken: token, identity: identity)
                    TMConversationManager.shared = conversationManger
                    
                    return conversationManger.promiseClient()
                    
                    }.then { client-> Void in
                        
                        super.synchronizeData()
                        
                    }.catch { error in
                        
                        JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                }
            }
            else {
                
                super.synchronizeData()
            }
        }
        else {
            super.synchronizeData()
        }
    }
    
    /// Fetch conversations parameters for current user
    ///
    /// - Returns: return conversation token and identity
    class func fetchConversation(identity: String, deviceID: String)-> Promise<(token: String, identity: String)> {
        
        // Request params
        let params = ["identity": identity, "device": deviceID]
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.post, path: "conversations/token", parameters: params).then { result-> (token: String, identity: String) in
            
            if let token = result["token"].string, let identity = result["identity"].string {
                
                return (token: token, identity: identity)
            }
            
            return (token: "", identity: "")
        }
    }
}
