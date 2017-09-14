//
//  TMPayment.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Stripe
import CoreStore
import SwiftyJSON
import PromiseKit

/// Struct that represent Payment JSON keys
public struct TMPaymentJSON {
    
    static let id = "id"
    static let userID = "user_id"
    static let externalID = "external_id"
    
    static let isDefault = "is_default"
    
    static let zip = "zip"
    static let brand = "brand"
    static let last4 = "last4"
    static let provider = "provider"
    
    static let expirationYear = "exp_year"
    static let expirationMonth = "exp_month"
    
    static let fingerprint = "fingerprint"
}

@objc(TMPayment)
public class TMPayment: _TMPayment {

    /// Display string with 4 last digits
    ///
    /// - Parameter creditCard: creditCard object
    /// - Returns: formatted string
    class func displayNumber(creditCard: TMPayment?)-> String {
        
        guard let _creditCard = creditCard else {
            
            return ""
        }
        
        if _creditCard.last4 != nil {
            var numberFormat = ""
            if _creditCard.brand?.lowercased() == "american express" {
                numberFormat = "•••• •••••• •%@";
            }
            else {
                numberFormat = "•••• •••• •••• %@";
            }
            
            return String(format: numberFormat, _creditCard.last4!)
        }
        else {
            return "•••• •••• •••• ••••"
        }
    }
    
    /// Returns payment brand image
    ///
    /// - Parameter brand: brand type
    /// - Returns: image
    class func cardImage(brand: String?)-> UIImage? {
        
        var cardImageName = "placeholder"
        
        if brand != nil {
            let lowercaseBrand = brand!.lowercased()
            
            if lowercaseBrand == "american express" {
                cardImageName = "stp_card_amex"
            }
            else if lowercaseBrand == "diners club" {
                cardImageName = "stp_card_diners"
            }
            else if lowercaseBrand == "discover" {
                cardImageName = "stp_card_discover"
            }
            else if lowercaseBrand == "jcb" {
                cardImageName = "stp_card_jcb"
            }
            else if lowercaseBrand == "mastercard" {
                cardImageName = "stp_card_mastercard"
            }
            else if lowercaseBrand == "visa" {
                cardImageName = "stp_card_visa"
            }
        }
        
        return UIImage(named: cardImageName, in: Bundle(for: STPAPIClient.classForCoder()), compatibleWith: nil)
    }
    
    override func updateModel(with source: JSON, transaction: BaseDataTransaction) throws {
        
        try super.updateModel(with: source, transaction: transaction)
        
        // User ID
        self.userID = source[TMPaymentJSON.userID].string
        
        // External ID
        self.externalID = source[TMPaymentJSON.externalID].string
        
        // Is Default Payment
        self.isDefault = source[TMPaymentJSON.isDefault].boolNumber
        
        // Postal code
        self.postal = source[TMPaymentJSON.zip].string
        
        // Payment brand
        self.brand = source[TMPaymentJSON.brand].string
        
        // Last 4 numbers
        self.last4 = source[TMPaymentJSON.last4].string
        
        // Payment provider
        self.provider = source[TMPaymentJSON.provider].string
        
        // Expiration Year Number
        self.expirationYear = source[TMPaymentJSON.expirationYear].string
        
        // Expiration Month Number
        self.expirationMonth = source[TMPaymentJSON.expirationMonth].string
        
        // Payment fingerprint
        self.fingerprint = source[TMPaymentJSON.fingerprint].string
    }
}
