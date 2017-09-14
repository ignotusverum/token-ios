//
//  TMDoubleCreateAccountCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/11/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import JDStatusBarNotification

import EZSwiftExtensions

class TMDoubleCreateAccountCell: TMCreateAccountCell {
    
    @IBOutlet var titleLabelSecond: TMLabel! {
        didSet {
            
            self.titleLabelSecond.font = self.titleLabelSecond.font!.withSize(self.getFontSize())
            
            if let titleText = self.titleLabelSecond.text {
                
                let textWithSpaces = titleText.setCharSpacing(1.0)
                self.titleLabelSecond.attributedText = textWithSpaces
            }
        }
    }
    
    @IBOutlet var textFieldSecond: UITextField!
    
    @IBOutlet var validationLineViewSecond: UIView!
    
    fileprivate var oldPlaceholderSecond: String?
    
    override func customInit() {
        super.customInit()
        
        self.textFieldSecond.addTarget(self, action: #selector(TMCreateAccountCell.textFieldDidChange), for: UIControlEvents.editingChanged)
        
        self.oldPlaceholderSecond = self.textFieldSecond.placeholder

        self.titleLabelSecond.textColor = UIColor.TMColorWithRGBFloat(170, green: 170, blue: 170, alpha: 1)
        
        self.validationLineViewSecond.backgroundColor = UIColor.TMGrayCell
        
        if DeviceType.IS_IPHONE_6P {
            
            self.titleLabelSecond.font = UIFont.MalloryMedium(15.0)
            self.textFieldSecond.font = UIFont.ActaBook(20.0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textFieldSecond.attributedPlaceholder = NSAttributedString(string: textFieldSecond.placeholder!, attributes: [NSForegroundColorAttributeName : textFieldPlaceholderColor])
    }
    
    override func validateTextField(_ textField: UITextField) {
        
        super.validateTextField(textField)
        
        var validateNumber = 0
        var validationResult = false
        
        if !TMInputValidation.isValidName(textField.text) {
            validateNumber = validateNumber + 1
        }
        
        if !TMInputValidation.isValidName(textFieldSecond.text) {
            validateNumber = validateNumber + 1
        }
        
        if validateNumber > 0 {
            validationResult = false
        }
        else {
            validationResult = true
        }
        
        self.delegate?.validationSuccessForCell(self, success: validationResult)
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.delegate?.textEditingDidBegin(textFieldSecond)
        
        if textField == self.textField {
            
            super.textFieldDidBeginEditing(textField)
            
        }
        else {
            
            textFieldSecond.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName : textFieldPlaceholderColor])
            
            self.validationLineViewSecond.backgroundColor = validationLineSelectedColor
            
            self.delegate?.textEditingDidEnd(textField)
        }
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.textField {
            
            super.textFieldDidEndEditing(textField)
            
            if !TMInputValidation.isValidName(textField.text) && (textField.text?.length)! > 0 {
                JDStatusBarNotification.show(withStatus: "Wrong First Name", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }
        else {
        
            self.textFieldSecond.placeholder = self.oldPlaceholderSecond
            self.textFieldSecond.attributedPlaceholder = oldPlaceholderSecond?.color(self.placeholderColor)

            self.validationLineViewSecond.backgroundColor = UIColor.TMGrayCell
                        
            self.delegate?.textEditingDidEnd(self.textFieldSecond)
            
            if !TMInputValidation.isValidName(self.textFieldSecond.text) && (textFieldSecond.text?.length)! > 0 {
                JDStatusBarNotification.show(withStatus: "Wrong Last Name", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }
    }
}
