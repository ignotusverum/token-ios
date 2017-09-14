//
//  TMContactInfoFreeFormCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 9/29/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMContactInfoFreeFormCollectionViewCell: UICollectionViewCell {
    
    // Info label (age/relation)
    @IBOutlet weak var infoInput: UITextField!
    
    @IBOutlet weak var pencilIcon: UIImageView!
    
    var gradientBorder = CAGradientLayer()
    
    func addCellGradienBorder() {
        
        guard let sublayers = layer.sublayers else {
            return
        }
        
        if !sublayers.contains(self.gradientBorder) {
            
            gradientBorder = addGradienBorder()
        }
    }
    
    func removeGradientLayer() {
        
        gradientBorder.removeFromSuperlayer()
    }
}
