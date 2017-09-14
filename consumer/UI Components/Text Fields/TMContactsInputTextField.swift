//
//  TMContactsInputTextField.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/12/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//


class TMContactsInputTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        
        return bounds.insetBy(dx: 10.0, dy: 10.0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds)
        
        return bounds.insetBy(dx: 10.0, dy: 10.0)
    }
}
