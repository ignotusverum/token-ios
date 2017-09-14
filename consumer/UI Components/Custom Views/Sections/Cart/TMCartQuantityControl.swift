//
//  TMCartQuantityControl.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/10/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

protocol TMCartQuantityControlDelegate {
    func addButtonPressedWithItem()
    func removeButtonPressedWithItem()
}

class TMCartQuantityControl: UIView {
    
    // delegate
    var delegate: TMCartQuantityControlDelegate?
    
    // Quantity
    var quantity = 1 {
        didSet {
            
            if quantity > 0 {
                self.label.text = quantity.toString
            }
            else {
                quantity = 1
            }
        }
    }
    
    @IBOutlet var buttons: [UIButton]!
    
    // Initial View
    @IBOutlet var view: UIView!
    
    // Quantity Label
    @IBOutlet var label: UILabel!
    
    // Quantity button action
    @IBAction func quantityButtonPressed(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            self.quantity = self.quantity + 1
            self.delegate?.addButtonPressedWithItem()
            
        default:
            
            if self.quantity > 1 {
                self.delegate?.removeButtonPressedWithItem()
            }
            
            self.quantity = self.quantity - 1
        }
    }
    
    // Init from xib
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("TMCartQuantityControl", owner: self, options: nil)
        self.addSubview(view)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions.alignAllCenterY , metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions.alignAllCenterX , metrics: nil, views: ["view": self.view]))
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalIn: CGRect(x: self.label.centerX + 10.5
            , y: -4.0, w: 22.0, h: 22.0)).cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.black.cgColor
        circleLayer.lineWidth = 1.0
        
        self.label.layer.addSublayer(circleLayer)
    }
}
