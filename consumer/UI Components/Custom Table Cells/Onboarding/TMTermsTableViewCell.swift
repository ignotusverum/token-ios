//
//  TMTermsTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMTermsTableViewCell: TMCreateAccountCell {

    // Terms label
    @IBOutlet var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Attributed text
        self.label.attributedText = TMCopy.termsCopy
    }
}
