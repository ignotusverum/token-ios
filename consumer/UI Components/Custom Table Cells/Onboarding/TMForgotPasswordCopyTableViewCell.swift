//
//  TMForgotPasswordCopyTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 9/7/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMForgotPasswordCopyTableViewCell: UITableViewCell {

    @IBOutlet weak var copyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let copyStyle = NSMutableAttributedString.initWithString(copyLabel.text!, lineSpacing: 5.0, aligntment: .center)
        copyStyle.addAttribute(NSFontAttributeName, value: UIFont.ActaBook(), range: NSMakeRange(0, copyStyle.length))
        self.copyLabel.attributedText = copyStyle
    }
}
