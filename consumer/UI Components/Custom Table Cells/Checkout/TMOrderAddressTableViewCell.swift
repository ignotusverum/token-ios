//
//  TMOrderAddressTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 6/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import EZSwiftExtensions

class TMOrderAddressTableViewCell: UITableViewCell {

    // Address
    var address: TMContactAddress? {
        didSet {
            // Safety check
            guard let _address = address else {
                return
            }
            
            let addressNameString = _address.label?.capitalizedFirst()
            
            // Name Setup
            self.nameLabel.attributedText = addressNameString?.setCharSpacing(0.4)
            
            // Details Setup
            let addressDetailString = TMContactAddress.getAddressDetailsStringFromAddress(_address).uppercasedPrefix(0)
            
            self.detailsLabel.attributedText = addressDetailString.setCharSpacing(1.0)
        }
    }
    
    // Address name label
    @IBOutlet var nameLabel: UILabel!
    
    // Address details label
    @IBOutlet var detailsLabel: UILabel!
}
