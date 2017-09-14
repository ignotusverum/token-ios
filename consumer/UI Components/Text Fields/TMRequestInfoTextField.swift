//
//  TMRequestInfoTextField.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/21/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMRequestInfoTextField: UITextField {
    
    var textUnderline = UIView()
    
    var gradientLayer = CAGradientLayer()
    
    var yPos: CGPoint?
    
    var placeholderAttributes: [String: Any] = [ NSFontAttributeName: UIFont.MalloryBook(12.0),
                                                 NSForegroundColorAttributeName: UIColor.TMColorWithRGBFloat(155.0, green: 155.0, blue: 155.0, alpha: 10),
                                                 NSKernAttributeName: 1.0
    ]
    
    var textAttributes: [String: Any] = [ NSFontAttributeName: UIFont.MalloryBook(12.0),
                                          NSForegroundColorAttributeName: UIColor.black,
                                          NSKernAttributeName: 1.0
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        textAttributes[NSParagraphStyleAttributeName] = paragraphStyle
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: placeholderAttributes)
        
        self.addTarget(self, action: #selector(TMRequestInfoTextField.textDidChange(_:)), for: .editingChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layoutIfNeeded()
        
        if self.yPos == nil {
            self.yPos = self.superview!.convert(self.frame.origin, to: nil)
        }
        
        if !self.superview!.subviews.contains(textUnderline) {
            
            self.addUnderline()
        }
        else {
            
            if let _ = self.attributedPlaceholder {
                self.textUnderline.removeFromSuperview()
                
                self.addUnderline()
            }
        }
    }
    
    func addUnderline() {
        
        textUnderline.frame = CGRect(x: 0.0, y: yPos!.y + self.frame.height + 3.0, width: self.frame.size.width, height: 1.0)
        self.textUnderline.setFrameWidth(self.attributedPlaceholder!.widthWithConstrainedHeight(self.frameHeight()) + 150.0)
        
        self.textUnderline.centerX = self.center.x
        
        self.gradientLayer.removeFromSuperlayer()
        self.gradientLayer = textUnderline.addGradienBorder()
        
        self.superview?.addSubviewWithCheck(textUnderline)
    }
    
    func textDidChange(_ textField: UITextField) {
        
        self.typingAttributes = textAttributes
        
        let attributedString = textField.attributedText
        
        if textField.text!.length >= 15 {
            UIView.animate(withDuration: 0.1) {
                
                self.gradientLayer.removeFromSuperlayer()
                
                let frameNew = attributedString!.widthWithConstrainedHeight(self.frameHeight()) + 140.0
                
                if frameNew < self.superview!.frame.width - 80.0 {
                    
                    self.textUnderline.setFrameWidth(frameNew)
                }
                
                self.gradientLayer = self.textUnderline.addGradienBorder()
            }
            
            self.textUnderline.centerX = self.center.x
        }
        else {
            
            self.resetUnderline()
        }
    }
    
    func resetUnderline() {
        
        textUnderline.frame = CGRect(x: 0.0, y: yPos!.y + self.frame.height + 3.0, width: self.frame.size.width, height: 1.0)
        let defaultString = "Brooklyn, NY".setCharSpacing(1.0)
        self.textUnderline.setFrameWidth(defaultString.widthWithConstrainedHeight(self.frameHeight()) + 150.0)
        
        self.textUnderline.centerX = self.center.x
        
        self.gradientLayer.removeFromSuperlayer()
        self.gradientLayer = textUnderline.addGradienBorder()
    }
    
    override func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        
        self.layoutIfNeeded()
        
        return resigned
    }
}

extension TMRequestInfoTextField: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: placeholderAttributes)
    }
}
