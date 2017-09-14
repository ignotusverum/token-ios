//
//  TMRequestStatusLabel.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 9/27/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMRequestStatusView: UIView {

    // request for status
    var request: TMRequest! {
        didSet {
            
            self.customInit()
        }
    }
    
    // label
    @IBOutlet weak var label: UILabel!

    // Gradient
    fileprivate var goldGradient = CAGradientLayer()
    
    let selectionBackgroundColor = UIColor.TMColorWithRGBFloat(255.0, green: 103.0, blue: 93.0, alpha: 1.0)
    
    let purchaseTextColor = UIColor.TMColorWithRGBFloat(174.0, green: 124.0, blue: 88.0, alpha: 1.0)
    
    let deliveryBackgroundColor = UIColor.TMColorWithRGBFloat(61.0, green: 37.0, blue: 50.0, alpha: 1.0)
    
    let shippedTextColor = UIColor.TMColorWithRGBFloat(174.0, green: 124.0, blue: 88.0, alpha: 1.0)
    
    // Custom init
    func customInit() {
        
        // UI Setup
        self.customUISetup()
        
        // Text Setup
        self.textSetup()
    }
    
    func textSetup() {
        
        guard let requestStatus = self.request.displayStatus else {
            
            return
        }
        
        self.label.attributedText = requestStatus.uppercased().setCharSpacing(0.8)
        
        if DeviceType.IS_IPHONE_5 {
            self.label.font = UIFont.ActaBook(10.0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutSubviews()
        
        self.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.goldGradient.frame = self.bounds
    }
    
    func customUISetup() {
        
        self.layer.borderWidth = 0.3
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.clear.cgColor
        
        self.removeGradient()
        
        switch self.request.status {
        case .pending:
            // Add pending gradient
            self.addGradient()
            self.label.textColor = UIColor.white
            
        case .selection:
            
            let seen = request.recommendationArray.last?.seen?.boolValue ?? false
            if seen == true {
                
                self.label.textColor = self.selectionBackgroundColor
                self.layer.borderColor = self.selectionBackgroundColor.cgColor
            }
            else {
                
                self.backgroundColor = self.selectionBackgroundColor
                self.label.textColor = UIColor.white
            }
            
        case .purchase:
            
            self.label.textColor = self.purchaseTextColor
            self.layer.borderColor = self.purchaseTextColor.cgColor
            
        case .shipment:
            
            self.label.textColor = self.shippedTextColor
            self.layer.borderColor = self.shippedTextColor.cgColor
            
        case .delivery:
            
            self.label.textColor = self.deliveryBackgroundColor
            self.layer.borderColor = self.deliveryBackgroundColor.cgColor
        }
    }
    
    override func addGradient(_ index: UInt32 = 1) {
        
        guard let sublayers = layer.sublayers else {
            return
        }
        
        if !sublayers.contains(self.goldGradient) {
            goldGradient = CAGradientLayer()
            goldGradient.frame = self.bounds
            
            goldGradient.colors = [UIColor.firstGradientColor.cgColor, UIColor.secondGradientColor.cgColor]
            goldGradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            goldGradient.endPoint = CGPoint(x: 1.0, y: 0.3)
            
            layer.insertSublayer(self.goldGradient, at: 0)
        }
    }
    
    func removeGradient() {
        
        self.goldGradient.removeFromSuperlayer()
    }
}
