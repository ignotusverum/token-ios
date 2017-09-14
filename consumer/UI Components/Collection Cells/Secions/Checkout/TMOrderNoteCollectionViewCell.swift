//
//  TMOrderNoteCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/31/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import EZSwiftExtensions

class TMOrderNoteCollectionViewCell: UICollectionViewCell {

    // Request
    var request: TMRequest? {
        didSet {
            
            // Safety check
            guard let _request = request else {
                return
            }
            
            // Receiver name
            self.receiverName = _request.contact?.availableName
            
            // Sender name
            let config = TMConsumerConfig.shared
            let user = config.currentUser
            
            self.senderName = user?.firstName
        }
    }
    
    // Names - ivars
    var receiverName: String? {
        didSet {
            // Safety check
            guard let _receiverName = receiverName else {
                return
            }
            
            // Setting textField text
            self.receiverTextField.text = _receiverName
        }
    }
    
    var senderName: String? {
        didSet {
            // Safety check
            guard let _senderName = senderName else {
                return
            }
            
            // Setting textField text
            self.senderTextField.text = _senderName
        }
    }
    
    var senderOldName: String?
    
    // Outlets
    @IBOutlet var receiverTextField: UITextField!
    
    @IBOutlet var senderTextField: UITextField!
}
