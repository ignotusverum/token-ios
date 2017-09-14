//
//  TMOnboardingTextField.swift
//  consumer
//
//  Created by Vlad Zagorodnyuk on 4/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMOnboardingTextField: TMLayoutTextField {
    
    // MARK: - Custom Initialization
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        if DeviceType.IS_IPHONE_6P {
            return bounds.insetBy(dx: 0.0, dy: 15.0)
        }
        
        return bounds.insetBy(dx: 0.0, dy: 12.0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        if DeviceType.IS_IPHONE_6P {
            return bounds.insetBy(dx: 0.0, dy: 15.0)
        }
        
        return bounds.insetBy(dx: 0.0, dy: 12.0)
    }
}
