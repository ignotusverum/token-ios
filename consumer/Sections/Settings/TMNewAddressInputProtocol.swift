//
//  TMNewAddressTextFieldProtocol.swift
//  consumer
//
//  Created by Gregory Sapienza on 1/19/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

protocol TMNewAddressInputProtocol: class {
    
    /// Selection value.
    associatedtype T
    
    /// Data backing input.
    associatedtype U
    
    /// View.
    associatedtype V
    
    /// Data to back the input view.
    var backingData: U? { get set }
    
    /// The text field providing the input view.
    var textField: UITextField? { get set }
    
    /// Is text entry allowed while using this input view.
    var textEntryAllowed: Bool { get set }
    
    
    /// Reload data.
    ///
    /// - Parameter view: Input view where data should be reloaded.
    func reloadData(view: V)
    
    /// Select a value for the input view.
    ///
    /// - Parameters:
    ///   - view: Input view.
    ///   - value: Value selection.
    func selectValue(view: V, value: T)
    
    /// Get the selected value for the input view.
    ///
    /// - Parameter view: Input view.
    /// - Returns: The selected value within the input view.
    func selectedValue(view: V) -> T
    
    /// Generate a new view to use for input view.
    ///
    /// - Returns: The view to use for input view.
    func generate() -> V
    
    /// Setup for any subviews to display on text field.
    func loadTextfieldSubviews()
        
    /// Action when the text field has began editing.
    func textFieldDidBeginEditing()
    
    /// Action
    ///
    /// - Returns: True if the text field should end editing, false if it should not.
    func textFieldShouldEndEditing() -> Bool
}
