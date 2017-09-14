//
//  TMPhoneVerificationTextField.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/26/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMPhoneVerificationTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        if DeviceType.IS_IPHONE_5 {
            
            return bounds.insetBy(dx: 8.0, dy: 5.0)
        }
        
        return bounds.insetBy(dx: 8.0, dy: 7.0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        if DeviceType.IS_IPHONE_5 {
            return bounds.insetBy(dx: 8.0, dy: 5.0)
        }
        
        return bounds.insetBy(dx: 3.0, dy: 7.0)
    }
}
