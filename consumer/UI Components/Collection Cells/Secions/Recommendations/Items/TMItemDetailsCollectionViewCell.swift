//
//  TMItemDetailsCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/5/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMItemDetailsCollectionViewCell: TMDynamicHeightCollectionViewCell {
    
    // Item
    var item: TMItem? {
        didSet {
            guard let _item = item else {
                
                return
            }
            
            // Setup item description
            self.contentLabel.text = _item.itemDescription
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.layer.masksToBounds = true
    }
    
    // In layoutSubViews, need set preferredMaxLayoutWidth for multiple lines label
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set what preferredMaxLayoutWidth you want
        contentLabel.preferredMaxLayoutWidth = self.bounds.width - 2 * kLabelHorizontalInsets
    }
}
