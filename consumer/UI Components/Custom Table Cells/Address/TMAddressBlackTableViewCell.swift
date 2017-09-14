//
//  TMAddressBlackTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 6/10/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMAddressBlackTableViewCell: TMAddressTableViewCell {

    let detailsColor = UIColor.TMColorWithRGBFloat(162.0, green: 161.0, blue: 163.0, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Changing UI colors
        self.titleLabel.textColor = UIColor.white
        
        self.addressLabel.textColor = detailsColor
        
        // Hiding unusable elements
        self.editingButton.isHidden = true
        
        // Setting address image
        self.selectionImageView.tintColor = UIColor.white
        self.selectionImageView.image = UIImage(named: "AddressPin")
    }
}
