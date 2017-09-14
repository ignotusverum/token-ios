//
//  TMPaymentScanCardTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/24/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMPaymentScanCardTableViewCell: TMPaymentTableViewCell {
    
    @IBOutlet var scanCardButton: UIButton!
    
    // Style
    override var lightStyle: Bool {
        didSet {
            if lightStyle {
                
                self.scanCardButton.setTitleColor(UIColor.black, for: .normal)
                self.scanCardButton.layer.borderColor = UIColor.black.cgColor
            }
            else {
                
                self.scanCardButton.setTitleColor(UIColor.white, for: .normal)
                self.scanCardButton.layer.borderColor = UIColor.white.cgColor
            }
            
            self.scanCardButton.setTitleColor(UIColor.TMGrayColor, for: .highlighted)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.scanCardButton.layer.borderWidth = 0.8
    }
}
