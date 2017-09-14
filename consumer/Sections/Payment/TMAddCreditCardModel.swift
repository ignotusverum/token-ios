//
//  TMAddCreditCardModel.swift
//  consumer
//
//  Created by Gregory Sapienza on 3/15/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation
import Stripe
import PromiseKit

/// Error when validating credit card with Stripe.
private enum CreditCardValidatingError: Error, LocalizedError {
    case name
    case creditCardNumber
    case cvv
    case expiration
    case zipCode
    
    var errorDescription: String? {
        switch self {
        case .name:
            return "Could not validate name on credit card"
        case .creditCardNumber:
            return "Could not validate credit card number"
        case .cvv:
            return "Could not validate CVV code"
        case .expiration:
            return "Could not validate expiration date"
        case .zipCode:
            return "Could not validate zip code"
        }
    }
}

struct TMAddCreditCardModel {
    
    // MARK: - Private iVars
    
    /// Data to use to display collection view.
    fileprivate let allPaymentFields = TMAddCreditCardPaymentDataType.displaySections()
    
    /// Data backing each payment field.
    fileprivate lazy var paymentData: [TMAddCreditCardPaymentDataType : String] = {
        var backingData: [TMAddCreditCardPaymentDataType : String] = [ : ]
        
        for paymentField in TMAddCreditCardPaymentDataType.all() {
            backingData[paymentField] = ""
        }
        
        return backingData
    }()
    
    /// Array containing all payment fields that still need verification.
    fileprivate var nonVerifiedPaymentFields = Set(TMAddCreditCardPaymentDataType.all())
    
    // MARK: - Class Funcs
    
    /// Gets credit card brand for a credit card number.
    ///
    /// - Parameter cardNumber: Card number used to determine brand.
    /// - Returns: Card brand based on card number.
    static func getCreditCardBrand(_ cardNumber: String) -> STPCardBrand {
        return STPCardValidator.brand(forNumber: cardNumber)
    }
    
    // MARK: - Public

    /// Sets payment backing data for a specified type. Removes all decorators from string and attempts to verify it.
    ///
    /// - Parameters:
    ///   - string: String to use as data for a payment field.
    ///   - type: Type of field to set data as.
    mutating func setPaymentData(_ string: String, for type: TMAddCreditCardPaymentDataType) {
        let text = type.textDecoratorStripper(text: string) //Remove decorators.
        
        paymentData[type] = text //Set the text to the stripped text.
        
        var cardType = TMAddCreditCardModel.getCreditCardBrand("")
        
        if let cardNumber = paymentData(for: .creditCardNumber) {
            cardType = TMAddCreditCardModel.getCreditCardBrand(cardNumber)
        }
        
        //---Verify---//
        
        if type.verify(for: text, cardType: cardType) {
            verifyFieldType(type)
        } else {
            unverifyFieldType(type)
        }
    }
    
    /// Retrieves payment data for a payment type.
    ///
    /// - Parameter paymentType: Payment type to retrieve data for.
    /// - Returns: String representing data for payment type.
    mutating func paymentData(for paymentType: TMAddCreditCardPaymentDataType) -> String? {
        return paymentData[paymentType]
    }
    
    /// Retrieves payment type for an index path.
    ///
    /// - Parameter indexPath: Index path used to get payment type.
    /// - Returns: Payment type for index path.
    mutating func paymentField(for indexPath: IndexPath) -> TMAddCreditCardPaymentDataType {
        return allPaymentFields[indexPath.section][indexPath.item]
    }
    
    /// Retrieves all payment fields in a section.
    ///
    /// - Parameter section: Section containing fields to retreive.
    /// - Returns: Array of payment field types within specified section.
    func paymentFields(for section: Int) -> [TMAddCreditCardPaymentDataType] {
        return allPaymentFields[section]
    }
    
    /// Retrieves all payment sections containg fields.
    ///
    /// - Returns: Array of arrays containing payment fields.
    func paymentFieldSections() -> [[TMAddCreditCardPaymentDataType]] {
        return allPaymentFields
    }
    
    /// Determines if all payment fields have been verified.
    ///
    /// - Returns: True if all fields have been verified.
    func allFieldTypesVerified() -> Bool {
        return nonVerifiedPaymentFields.isEmpty
    }
    
    /// Determines if a particular field type has been verified.
    ///
    /// - Parameter type: Type of payment field to check if verified.
    /// - Returns: True if the payment field was verified.
    func fieldVerified(for type: TMAddCreditCardPaymentDataType) -> Bool {
        return !nonVerifiedPaymentFields.contains(type)
    }
    
    /// Imports data from credit card image data.
    ///
    /// - Parameter cardInfo: Card info containing data from the credit card image.
    mutating func importScannedCreditCardData(from cardInfo: CardIOCreditCardInfo) {
        
        //---Name---//
        
        if let cardholderName = cardInfo.cardholderName {
            setPaymentData(cardholderName, for: .name)
        }
        
        //---Card Number---//
        
        if let cardNumber = cardInfo.cardNumber {
            setPaymentData(cardNumber, for: .creditCardNumber)
        }
        
        //---Expiration Date---//
        
        let expirationMonth = cardInfo.expiryMonth
        let expirationYear = cardInfo.expiryYear
        
        //Expiration is 4 characters. First 2 are the month, last 2 are the year. This splits it up.
        let originalExpirationYearString = "\(expirationYear)"
        let substringIndex = originalExpirationYearString.index(originalExpirationYearString.startIndex, offsetBy: 2)
        let expirationYearString = originalExpirationYearString.substring(from: substringIndex)
        
        // Expiration month should have '0' if it's < 10
        var monthFormat = ""
        if expirationMonth < 10 {
            monthFormat = "0"
        }
        
        setPaymentData("\(monthFormat)\(expirationMonth)\(expirationYearString)", for: .expiration)
        setPaymentData(cardInfo.cvv, for: .cvv)
    }
    
    /// Attempts to validate card data and save credit card from backing data in model.
    ///
    /// - Parameter completion: Completion when saving with possible error.
    mutating func saveCreditCardFromPaymentData(completion: @escaping (Error?) -> Void) {
        guard
            let name = paymentData(for: .name),
            let creditCardNumber = paymentData(for: .creditCardNumber),
            let cvv = paymentData(for: .cvv),
            let expiration = paymentData(for: .expiration),
            let zip = paymentData(for: .zipCode)
            else {
                return
        }
        
        let expirationMonth = expiration.substring(to: expiration.index(expiration.startIndex, offsetBy: 2))
        let expirationYear = expiration.substring(from: expiration.index(expiration.startIndex, offsetBy: 2))
        
        //---Validation---//
    
        do {
            try validateCreditCard(creditCardNumber:creditCardNumber, expirationMonth: expirationMonth, expirationYear: expirationYear, cvv: cvv)
        } catch {
            completion(error)
        }
        
        //---Saving---//
        
        saveCreditCard(name: name, creditCardNumber: creditCardNumber, expirationMonth: expirationMonth, expirationYear: expirationYear, cvv: cvv, zip: zip) { error in
            completion(error)
        }
    }
    
    /// Determines credit card brand from number stored in model data.
    ///
    /// - Returns: Credit card brand for credit card number.
    mutating func creditCardBrandFromPaymentData() -> STPCardBrand {
        var cardType = TMAddCreditCardModel.getCreditCardBrand("")
        
        if let cardNumber = paymentData(for: .creditCardNumber) {
            cardType = TMAddCreditCardModel.getCreditCardBrand(cardNumber)
        }
        
        return cardType
    }
    
    // MARK: - Private
    
    /// Verifies a payment field type using the types own basic verification method.
    ///
    /// - Parameter type: Type to verify.
    private mutating func verifyFieldType(_ type: TMAddCreditCardPaymentDataType) {
        nonVerifiedPaymentFields.remove(type)
    }
    
    /// Unverifies a payment field type using the types own basic verification method.
    ///
    /// - Parameter type: Type to unverify.
    private mutating func unverifyFieldType(_ type: TMAddCreditCardPaymentDataType) {
        nonVerifiedPaymentFields.insert(type)
    }
    
    /// Validates card data with Stripe.
    ///
    /// - Parameters:
    ///   - creditCardNumber: Credit card number.
    ///   - expirationMonth: Expiration month.
    ///   - expirationYear: Expiration year.
    ///   - cvv: CVV.
    /// - Throws: Error if card could not be validated.
    private func validateCreditCard(creditCardNumber: String, expirationMonth: String, expirationYear: String, cvv: String) throws {
        
        // CC Number validation
        guard STPCardValidator.validationState(forNumber: creditCardNumber, validatingCardBrand: false) == .valid else {
            throw CreditCardValidatingError.creditCardNumber
        }
        
        // Expiration year check
        guard STPCardValidator.validationState(forExpirationYear: expirationYear, inMonth: expirationMonth) == .valid else {
            throw CreditCardValidatingError.expiration
        }
        
        
        // CVV validation
        guard STPCardValidator.validationState(forCVC: cvv, cardBrand: TMAddCreditCardModel.getCreditCardBrand(creditCardNumber)) == .valid else {
            throw CreditCardValidatingError.cvv
        }
    }
    
    /// Saves credit card to database and server.
    ///
    /// - Parameters:
    ///   - name: Name on card.
    ///   - creditCardNumber: Credit card number.
    ///   - expirationMonth: Expiration month.
    ///   - expirationYear: Expiration year.
    ///   - cvv: CVV.
    ///   - zip: Zip code for the card's billing address.
    ///   - completion: Completion when saving with possible error.
    private func saveCreditCard(name: String, creditCardNumber: String, expirationMonth: String, expirationYear: String, cvv: String, zip: String, completion: @escaping (Error?) -> Void) {
        guard
            let expirationMonth = UInt(expirationMonth),
            let expirationYear = UInt(expirationYear)
            else {
                return
        }
        
        TMPaymentAdapter.addCardWithNumber(creditCardNumber, expirationMo: expirationMonth, expirationYear: expirationYear, cvcCode: cvv, zipCode: zip, name: name).then { response -> Promise<[TMPayment]> in
            
            return TMPaymentAdapter.fetchList()
            
            }.then { response -> Void in
                
                completion(nil)
                
            }.catch { error in
                completion(error)
        }
    }
}
