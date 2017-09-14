//
//  TMCreditCardView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMCreditCardView: UIView {

    var _creditCard: TMPayment?
    var creditCard: TMPayment? {
        get {
            return _creditCard
        }
        set {
            
            _creditCard = newValue
            
            if _creditCard != nil {
                
                self.cardNameLabel?.text = _creditCard?.label
                self.cardImageView?.image = TMPayment.cardImage(brand: _creditCard?.brand)
                self.cardNumberLabel?.text = TMPayment.displayNumber(creditCard: _creditCard)
                self.cardExpirationLabel?.text = String(format: "%@/%@", arguments: [(_creditCard?.expirationMonth)!,(_creditCard?.expirationYear)!])
            }
        }
    }
    
    @IBOutlet var cardNameLabel: UILabel?
    @IBOutlet var cardNumberLabel: UILabel?
    @IBOutlet var cardExpirationLabel: UILabel?
    @IBOutlet var cardPostalCodeLabel: UILabel?
    
    @IBOutlet var cardImageView: UIImageView?
}
