//
//  TMMenuLogoutTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/19/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMMenuLogoutTableViewCell: UITableViewCell {

    @IBOutlet var logoutButton: UIButton!

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.logoutButton.layer.borderWidth = 0.4
        self.logoutButton.layer.borderColor = UIColor.TMLightGrayColor.cgColor
    }
}
