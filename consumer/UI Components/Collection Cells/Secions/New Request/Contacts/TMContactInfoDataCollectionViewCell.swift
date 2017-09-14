//
//  TMContactInfoDataCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 9/28/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMContactInfoDataCollectionViewCell: UICollectionViewCell {
    
    // Info label (age/relation)
    @IBOutlet weak var infoLabel: UILabel!
    
    var gradientBorder = CAGradientLayer()
    
    func addCellGradienBorder() {
        
        guard let sublayers = layer.sublayers else {
            return
        }
        
        if !sublayers.contains(gradientBorder) {
        
            gradientBorder = addGradienBorder()
        }
    }
    
    func removeGradientLayer() {
        
        gradientBorder.removeFromSuperlayer()
    }
}
