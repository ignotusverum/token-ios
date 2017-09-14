//
//  TMCurrentProfileButtonView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/17/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMCurrentProfileButtonView: TMContactButtonView {

    var user: TMUser? {
        didSet {
            // Safety check
            guard let _user = user else {
                return
            }
            
            // Updating contact View
            self.contactView?.user = _user
        }
    }
    
    // Calling contact pressed delegate method
    @IBAction override func contactButtonPressed(_ sender: AnyObject) {
        self.delegate?.currentProfileButtonPressed()
    }
}
