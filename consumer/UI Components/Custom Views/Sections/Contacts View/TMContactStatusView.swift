//
//  TMContactStatusView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMContactStatusView: TMContactView {
    
    override func customInit() {
        
        super.customInit()
        
        if DeviceType.IS_IPHONE_5 {
            
            self.fullNameLabel.font = UIFont.ActaMedium(19.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.view.removeFromSuperview()
        
        Bundle.main.loadNibNamed("TMContactStatusView", owner: self, options: nil)
        self.addSubview(view)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions.alignAllCenterY , metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions.alignAllCenterX , metrics: nil, views: ["view": self.view]))
        
        self.customInit()
    }
}
