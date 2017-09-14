//
//  TMTokenDescriptionCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/21/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMTokenDescriptionCollectionViewCell: TMDynamicHeightCollectionViewCell {

    /// Custom shape layer defining content view shape.
    private lazy var customShapeLayer: CAShapeLayer = TMBubble.generateBubble()
    
    @IBOutlet weak var bubbleContainerView: UIView!
    
    // Item
    var item: TMItem? {
        didSet {
            guard let _item = item else {
                
                return
            }
            
            bubbleContainerView.layer.insertSublayer(customShapeLayer, below: contentLabel.layer)
            
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
        
        //---Custom Shape Layer---//
        
        customShapeLayer.path = TMBubble.generateInfoBubble(frame: bubbleContainerView.bounds)
        customShapeLayer.shadowPath = TMBubble.generateInfoBubble(frame: bubbleContainerView.bounds)
    }
}
