//
//  TMDynamicHeightCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/21/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMDynamicHeightCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    
    // Insets
    let kLabelHorizontalInsets: CGFloat = 20
    
    func configCell(_ content: String?, contentFont: UIFont) {
        
        if let content = content {
            contentLabel.attributedText = NSMutableAttributedString.initWithString(content, lineSpacing: 7.0, aligntment: .left)
            
            contentLabel.font = contentFont
        }
        else {
            contentLabel.text = ""
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}
