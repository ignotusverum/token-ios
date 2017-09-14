//
//  TMDoubleOnbourdingTextField.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/27/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMDoubleOnbourdingTextField: UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.custominit()
    }
    
    // MARK: - Custom Initialization
    func custominit() {
        
        self.font = self.font?.withSize(UIFont.defaultFontSize + 2)
        if let placeholder = self.placeholder {
            
            self.attributedPlaceholder = placeholder.setCharSpacing(0.4)
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        if DeviceType.IS_IPHONE_6P {
            return bounds.insetBy(dx: 0.0, dy: 15.0)
        }
        
        if DeviceType.IS_IPHONE_5 {
            return bounds.insetBy(dx: 0.0, dy: 10.0)
        }
        
        return bounds.insetBy(dx: 0.0, dy: 10.0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        if DeviceType.IS_IPHONE_6P {
            return bounds.insetBy(dx: 0.0, dy: 15.0)
        }
        
        if DeviceType.IS_IPHONE_5 {
            return bounds.insetBy(dx: 0.0, dy: 10.0)
        }
        
        return bounds.insetBy(dx: 0.0, dy: 10.0)
    }
}
