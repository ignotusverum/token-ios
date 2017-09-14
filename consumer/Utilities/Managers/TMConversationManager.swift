
//
//  TMConversationManager.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/8/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import PromiseKit
import TwilioChatClient

protocol TMConversationManagerDelegate {
    
    func messageAddedForChannel(_ channel: TCHChannel, message: TCHMessage)
}

class TMConversationManager: NSObject {
    
    // Shared conversation manager
    static var shared: TMConversationManager?
    
    var client: TwilioChatClient?
    
    // Delegate
    var delegate: TMConversationManagerDelegate?
    
    // Sender identity
    var identity = ""
    
    // Credentials
    var accessToken = ""
    
    func promiseClient()-> Promise<TwilioChatClient?> {
        
        return Promise { fulfill, reject in
            
            print(accessToken)
            TwilioChatClient.chatClient(withToken: accessToken, properties: nil, delegate: self, completion: { (result, client) in
                
                self.client = client
                fulfill(client)
            })
            
            TwilioChatClient.setLogLevel(.critical)
        }
    }
    
    init(accessToken: String, identity: String) {
        
        self.identity = identity
        self.accessToken = accessToken
        
        self.identity = identity
        
        super.init()
    }
    
    func synchronizeChannelForRequest(_ request: TMRequest?)-> Promise<TCHChannel?> {
        
        /// Safety checks
        guard let client = self.client, let channelID = request?.channelID else {
            return Promise(value: nil)
        }
        
        /// Main promise
        return Promise { fulfill, reject in
            
            /// Synchronize channel
            client.channelsList().channel(withSidOrUniqueName: channelID, completion: { (result, channel) in
                
                /// Check result
                guard let channel = channel else {
                    reject(TMError)
                    return
                }
                
                /// Synchronize channel
                fulfill(channel)
            })
        }
    }
    
    func fetchMessages(_ request: TMRequest, beginningIndex: Int, desiredNumberOfMessagesToLoad: Int)-> Promise<[TCHMessage]> {
        
        let messageResult = [TCHMessage]()
        
        var numberOfMessageToBeLoaded = desiredNumberOfMessagesToLoad //Number of messages that are to be loaded.
        
        return Promise { fulfill, reject in
            
            self.synchronizeChannelForRequest(request).then { channel-> Void in
                
                if let channel = channel {
                    
                    channel.getMessagesCount(completion: { (result: TCHResult?, count: UInt) in
                        // Setting messages to consumed
                        channel.messages.setAllMessagesConsumed()
                        
                        var inverseBeginningIndex = Int(count) - beginningIndex //Since we load backwards, we must inverse the beginning index based on the count.
                        
                        if inverseBeginningIndex < 0 { //If the inverse beginning index becomes a negative number then we must lower the amount of messages to be loaded because the remaining amount is less than the desiredAmountOfMessagesToLoad.
                            numberOfMessageToBeLoaded = inverseBeginningIndex + numberOfMessageToBeLoaded //Computes the remaining number of messages to load.
                            inverseBeginningIndex = 0 //We know we are at the end so this can just be 0.
                        }
                        
                        guard
                            numberOfMessageToBeLoaded > 0,
                            beginningIndex > 0
                            else { //These cannot be a negative.
                                fulfill([])
                                return
                        }
                        
                        // Getting list of messages
                        channel.messages.getAfter(UInt(inverseBeginningIndex), withCount: UInt(numberOfMessageToBeLoaded), completion: { (result, messages) in
                            
                            var resultMessages = [TCHMessage]()
                            
                            if let result = result, let messages = messages {
                                
                                resultMessages = messages
                                
                                // Successfull messages fetching
                                if result.isSuccessful() {
                                    
                                    fulfill(resultMessages)
                                }
                            }
                                // Error while fetching messages
                            else {
                                fulfill(messageResult)
                            }
                        })
                    })
                }
                
                }.catch { error-> Void in
                    
                    reject(error)
            }
        }
    }
}

// IP Messaging delegate
extension TMConversationManager: TwilioChatClientDelegate {
    
    func chatClient(_ client: TwilioChatClient!, channel: TCHChannel!, synchronizationStatusChanged status: TCHChannelSynchronizationStatus) {
        
        // Pass only fully synchronized channel
    }
    
    func chatClient(_ client: TwilioChatClient!, channel: TCHChannel!, messageAdded message: TCHMessage!) {
        
        delegate?.messageAddedForChannel(channel, message: message)
    }
}
