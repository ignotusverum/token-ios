//
//  TMTWMMessage.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 12/22/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import TwilioChatClient

extension TCHMessage {
    
    // Check if current user author
    func isReceiver()-> Bool {
        
        let config = TMConsumerConfig.shared
        let currentUser = config.currentUser
        
        // Safety check
        guard let currentUserID = currentUser?.id else {
            return true
        }
        
        // ID Check
        return currentUserID != self.author
    }
}
