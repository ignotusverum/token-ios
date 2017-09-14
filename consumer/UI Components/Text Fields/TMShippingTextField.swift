//
//  TMShippingTextField.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 7/25/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMShippingTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        if DeviceType.IS_IPHONE_6P {
            return bounds.insetBy(dx: 0.0, dy: 10.0)
        }
        
        return bounds.insetBy(dx: 0.0, dy: 15.0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        if DeviceType.IS_IPHONE_6P {
            return bounds.insetBy(dx: 0.0, dy: 10.0)
        }
        
        return bounds.insetBy(dx: 0.0, dy: 15.0)
    }
}
