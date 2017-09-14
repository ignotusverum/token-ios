//
//  TMPaymentCCNumberTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/23/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

// Payment
import Stripe

protocol TMPaymentCCNumberTableViewCellDelegate {
    func didChangeCCNumberText()
    func didFinishEnteringCCNumber()
}

class TMPaymentCCNumberTableViewCell: TMPaymentInputTableViewCell {
    
    // Delegate
    var delegate: TMPaymentCCNumberTableViewCellDelegate?
    
    // Style
    override var lightStyle: Bool {
        didSet {
            if lightStyle {
                
                self.cardImageView?.tintColor = UIColor.black
                self.separatorView.backgroundColor = lightColor
                
                self.cardNumberTextField.textColor = UIColor.black
            }
            else {
                
                self.cardImageView?.tintColor = UIColor.white
                self.separatorView.backgroundColor = darkColor
                
                self.cardNumberTextField.textColor = UIColor.white
            }
        }
    }
    
    // Card image View
    @IBOutlet var cardImageView: UIImageView!
    
    // Card Number title label
    @IBOutlet var titleLabel: UILabel!
    
    // Card Number text field
    var cardNumberTextField: TMCardNumberTextField!
    
    // Credit Card Brand
    var cardBrand = STPCardBrand.unknown {
        didSet {
            
            // Setting custom images for cc image view
            var imageName = ""
            
            switch cardBrand {
            case .visa:
                imageName = "VisaLarge"
                
            case .amex:
                imageName = "AmexLarge"
                
            case .masterCard:
                imageName = "MasterCardLarge"
                
            case .discover:
                imageName = "DiscoverLarge"
                
            case .JCB:
                imageName = "JCBLarge"
                
            case .dinersClub:
                imageName = "DinersClubLarge"
                
            default:
                imageName = "DefaultCreditCardLarge"
            }
            
            // Animate card change
            UIView.transition(with: self.cardImageView,
                              duration:0.1,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: { self.cardImageView?.image = UIImage(named: imageName) },
                              completion: nil)
        }
    }
    
    // Awake
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cardNumberTextField.customDelegate = self
        
        self.textField.contentVerticalAlignment = .center
        
        self.contentView.backgroundColor = UIColor.clear
    }
}

extension TMPaymentCCNumberTableViewCell: TMCardNumberTextFieldDelegate {
    // Text field did change
    func textFieldDidchangeWithNotification() {
        
        if self.textField.text != nil {
            
            // Setting card type
            self.cardBrand = STPCardValidator.brand(forNumber: self.textField.text!)
            
            self.delegate?.didChangeCCNumberText()
        }
    }
    
    // CC number finished
    func ccNumberTetFieldDidFinishedEntering() {
        self.delegate?.didFinishEnteringCCNumber()
    }
}
