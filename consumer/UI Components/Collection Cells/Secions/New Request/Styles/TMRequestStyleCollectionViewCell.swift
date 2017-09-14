//
//  TMRequestStyle
//  TMRequestStyleCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/15/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMRequestStyleCollectionViewCell: UICollectionViewCell {

    /// Style text label
    @IBOutlet weak var styleTitleLabel: UILabel!
    
    /// Max width constraint
    @IBOutlet weak var maxWidthConstraint: NSLayoutConstraint!

    var gradientBorder = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        clipsToBounds = true
        layer.masksToBounds = true
        
        layer.cornerRadius = bounds.midY
        addShadow(cornerRadius: bounds.midY)
    }
    
    func addCellGradientBorder() {
        
        guard let sublayers = layer.sublayers else {
            return
        }
        
        if !sublayers.contains(self.gradientBorder) {
            
            gradientBorder = addInnerGradientBorder(bounds.midY, lineWidth: 1.0)
        }
    }
    
    func removeGradientLayer() {
        
        gradientBorder.removeFromSuperlayer()
    }
}
