//
//  TMStandartButton.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/29/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMStandartButton: TMLayoutButton {
    
    var _backgroundColor: UIColor? {
        didSet {
            self.setBackgroundColor(_backgroundColor!, forState: .normal)
        }
    }
    
    var _disabledBackgroundColor: UIColor?
    var _highlightedBackgroundColor: UIColor?
    
    var _fontColor: UIColor?
    var _disabledFontColor: UIColor?
    var _highlightedFontColor: UIColor?
    
    var _borderColor: UIColor?
    var _disabledBorderColor: UIColor?
    var _hightlightedBorderColor: UIColor?
    
    var _borderWidth: CGFloat = 0.0
    var _cornerRadius: CGFloat = 0.0
    
    var shadowColor = UIColor.black
    
    var appearEnabled = true
    var shadowEnabled = true
    
    var animationPresented = false
    
    override var isEnabled: Bool {
        didSet {
            
            if isEnabled && self.appearEnabled {
                
                self.backgroundColor = _backgroundColor
                self.layer.borderColor = _borderColor?.cgColor
            }
            else {
                
                self.backgroundColor = _disabledBackgroundColor
                self.layer.borderColor = _disabledBorderColor?.cgColor
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            
            self.titleLabel?.alpha = 1.0
            
            if isHighlighted  {
                
                self.backgroundColor = _highlightedBackgroundColor
                self.layer.borderColor = _hightlightedBorderColor?.cgColor
            }
            else {
                
                if self.appearEnabled {
                    
                    self.backgroundColor = _backgroundColor
                    self.layer.borderColor = _borderColor?.cgColor
                }
                else {
                    
                    self.backgroundColor = _disabledBackgroundColor
                    self.layer.borderColor = _disabledBorderColor?.cgColor
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setDefaults()
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setDefaults()
        self.initialize()
    }
    
    // MARK: - Default UI initialization
    func setDefaults() {
        
        _backgroundColor = UIColor.TMButtonColor
        _disabledBackgroundColor = UIColor.TMDarkPinkColor
        _highlightedBackgroundColor = UIColor.TMDarkPinkColor
        
        _fontColor = UIColor.black
        _highlightedFontColor = UIColor.black
        _disabledFontColor = _highlightedFontColor
        
        _borderColor = UIColor.clear
        _hightlightedBorderColor = UIColor.black
        _disabledBorderColor = UIColor(white: 0.82, alpha: 1.0)
        
        _borderWidth = 0.5
        _cornerRadius = 2.6
    }
    
    func initialize() {
        
        if self.appearEnabled && self.isEnabled {
            
            self.backgroundColor = _backgroundColor
            self.layer.borderColor = _borderColor?.cgColor
            
            self.setTitleColor(_fontColor, for: .normal)
            self.setTitleColor(_fontColor, for: .selected)
        }
        else {
            
            self.backgroundColor = _disabledBackgroundColor
            self.layer.borderColor = _disabledBorderColor?.cgColor
            
            self.setTitleColor(_disabledFontColor, for: .normal)
            self.setTitleColor(_disabledFontColor, for: .selected)
        }
        
        if self.shadowEnabled {
            
            self.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 3
            self.layer.shadowOpacity = 0.2
        }
        
        self.setTitleColor(_hightlightedBorderColor, for: .highlighted)
        self.setTitleColor(_disabledFontColor, for: .disabled)
        
        self.layer.borderWidth = _borderWidth
        self.layer.cornerRadius = _cornerRadius
        
        self.titleLabel?.font = UIFont.MalloryMedium(14.0)
        self.titleLabel?.textAlignment = .center
        
        if self.titleLabel?.text != nil {
            let attributedString = NSMutableAttributedString(string: (self.titleLabel?.text)!)
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(1.4), range: NSRange(location: 0, length: (self.titleLabel?.text!.length)!))
            
            
            self.titleLabel!.attributedText = attributedString
        }
        
        self.setTitleShadowColor(UIColor.clear, for: .normal)
    }
    
    override var intrinsicContentSize: CGSize {
        
        let size = super.intrinsicContentSize
        
        return CGSize(width: size.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right, height: size.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom)
    }
}
