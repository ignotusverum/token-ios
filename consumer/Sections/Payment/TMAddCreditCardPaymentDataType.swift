//
//  TMCreditCardPaymentDataModel.swift
//  consumer
//
//  Created by Gregory Sapienza on 3/10/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import Stripe

/// Data model containing fields to display in new payment collection view.
///
/// - name: Name on credit card.
/// - creditCardNumber: Credit card number.
/// - expiration: Expiration date of credit card.
/// - cvv: Verification code on credit card.
/// - zipCode: Zip code of credit card billing address.
enum TMAddCreditCardPaymentDataType: String {
    case name = "Name"
    case creditCardNumber = "Card Number"
    case expiration = "Expiry"
    case cvv = "CVV"
    case zipCode = "Zip"
    
    // MARK: - Class Funcs

    /// Returns all cases in enum.
    ///
    /// - Returns: Array of possible cases for enum.
    static func all() -> [TMAddCreditCardPaymentDataType] {
        return [.name, .creditCardNumber, .expiration, .cvv, .zipCode]
    }
    
    /// Gets an array of sections to use for credit card payment collection view. Each section contains enums of fields to display together.
    ///
    /// - Returns: Array of sections that contain enums to be grouped together on display.
    static func displaySections() -> [[TMAddCreditCardPaymentDataType]] {
        let section1: [TMAddCreditCardPaymentDataType] = [.name]
        let section2: [TMAddCreditCardPaymentDataType] = [.creditCardNumber]
        let section3: [TMAddCreditCardPaymentDataType] = [.expiration, .cvv, .zipCode]
        
        return [section1, section2, section3]
    }
    
    // MARK: - Public

    /// Placeholder value for credit card payment text field.
    ///
    /// - Returns: String value to use as a placeholder for a credit card entry field.
    func placeholderText() -> String {
        switch self {
        case .name:
            return "Vince Staples"
        case .creditCardNumber:
            return "1234 5678 1234 5678"
        case .expiration:
            return "MM / YY"
        case .cvv:
            return "123"
        case .zipCode:
            return "12345"
        }
    }
    
    /// Keyboard type to use for text field type.
    ///
    /// - Returns: A keyboard type to use in a textfield when editing for a data type.
    func keyboardType() -> UIKeyboardType {
        switch self {
        case .name:
            return .default
        case .creditCardNumber:
            return .numberPad
        case .expiration:
            return .numberPad
        case .cvv:
            return .numberPad
        case .zipCode:
            return .numberPad
        }
    }
    
    /// Verifies string for field.
    ///
    /// - Parameter string: String to verify.
    /// - Returns: True if verfied.
    func verify(for string: String, cardType: STPCardBrand) -> Bool {
        
        let minCharactersRequirement = string.length >= minimumCharactersRequired(cardType: cardType)
        let maxCharacterRequirement = string.length <= maximumCharactersAllowed(cardType: cardType)

        return minCharactersRequirement && maxCharacterRequirement
    }
    
    
    /// Is more text allowed to be inputted by the user if the field was already verified.
    ///
    /// - Returns: True if the field is allowed further text after successful verification.
    func allowsTextAfterVerification() -> Bool {
        switch self {
        case .name:
            return true
        case .creditCardNumber:
            return false
        case .expiration:
            return false
        case .cvv:
            return false
        case .zipCode:
            return false
        }
    }
    
    /// Capitalization type for words in text field.
    ///
    /// - Returns: Capitalization type to use in a text field represented by type.
    func autocapitalizationType() -> UITextAutocapitalizationType? {
        switch self {
        case .name:
            return .words
        case .creditCardNumber:
            return nil
        case .expiration:
            return nil
        case .cvv:
            return nil
        case .zipCode:
            return nil
        }
    }
    
    /// Text handling for each field. Takes some text and adds various decorators to it based on the field.
    ///
    /// - Parameter text: Text to add decorators.
    /// - Parameter cardType: Type of credit card being used.
    /// - Returns: A new string based on the text passed where decorators have been applied.
    func textDecoratorHandler(text: String, cardType: STPCardBrand) -> String {
        let strippedString = textDecoratorStripper(text: text)

        switch self {
        case .name:
            return text
        case .creditCardNumber:

            var newText = "" //String to return.
            
            switch cardType {
            case .amex: //Amex cards adds spacing on the 4th and 10th number. This approach creates a bit of duplicate code for the different types of cards so it may be a good idea to clean this up a bit.
                for index in strippedString.characters.indices { //Iterate through each character.
                    let indexValue = strippedString.distance(from: strippedString.startIndex, to: index)
                    
                    if (indexValue == 4 || indexValue == 10) && indexValue != 0 { //For every 4 characters, insert a space. Except in the front of the string.
                        let space: Character = " "
                        
                        newText.append(space)
                    }
                    
                    newText.append(strippedString.characters[index])
                }
            default:
                for index in strippedString.characters.indices { //Iterate through each character.
                    let indexValue = strippedString.distance(from: strippedString.startIndex, to: index)
                    
                    if indexValue % 4 == 0 && indexValue != 0 { //For every 4 characters, insert a space. Except in the front of the string.
                        let space: Character = " "
                        
                        newText.append(space)
                    }
                    
                    newText.append(strippedString.characters[index])
                }
            }
            
            
            return newText
        case .expiration:

            var newText = "" //String to return.

            for index in strippedString.characters.indices { //Iterate through each character.
                let indexValue = strippedString.distance(from: strippedString.startIndex, to: index)
                
                if indexValue == 2 { //After the user types in a month add a seperator.
                    newText.append(" / ")
                }
                
                newText.append(strippedString.characters[index])
            }
            
            return newText
        case .cvv:
            return text
        case .zipCode:
            return text
        }
    }
    
    /// Removes text decoration for field. Takes text and removes decorators set by textDecoratorHandler.
    ///
    /// - Parameter text: Text to remove decorators.
    /// - Returns: A new string from the text passed without decorators.
    func textDecoratorStripper(text: String) -> String {
        switch self {
        case .name:
            return text
        case .creditCardNumber:
            let newText = text.replacingOccurrences(of: " ", with: "") //Removes spaces from text.
            
            return newText
        case .expiration:
            let newText = text.replacingOccurrences(of: " / ", with: "") //Removes seperator from month and year.
            
            return newText
        case .cvv:
            return text
        case .zipCode:
            return text
        }
    }
    
    // MARK: - Private
    
    /// Maximum characters required for each field type.
    /// - Parameter cardType: Type of credit card being used.
    /// - Returns: Integer of the maximum number of characters allowed.
    private func maximumCharactersAllowed(cardType: STPCardBrand) -> Int {
        switch self {
        case .name:
            return 100
        case .creditCardNumber:
            switch cardType {
            case .amex:
                return 15
            default:
                return 16
            }
        case .expiration:
            return 4
        case .cvv:
            switch cardType {
            case .amex:
                return 4
            default:
                return 3
            }
        case .zipCode:
            return 5
        }
    }
    
    /// Minimum characters required for each field type.
    ///
    /// - Parameter cardType: Type of credit card being used.
    /// - Returns: Integer of the minimum number of characters required.
    private func minimumCharactersRequired(cardType: STPCardBrand) -> Int {
        switch self {
        case .name:
            return 1
        case .creditCardNumber:
            switch cardType {
            case .amex:
                return 15
            default:
                return 16
            }
        case .expiration:
            return 4
        case .cvv:
            switch cardType {
            case .amex:
                return 4
            default:
                return 3
            }
        case .zipCode:
            return 5
        }
    }
}
