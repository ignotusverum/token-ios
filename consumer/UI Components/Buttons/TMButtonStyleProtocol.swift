//
//  TMButtonProtocol.swift
//  ButtonTest
//
//  Created by Gregory Sapienza on 2/21/17.
//  Copyright © 2017 Token. All rights reserved.
//

import UIKit

//MARK: - TMButtonStyleProtocol

protocol TMButtonStyleProtocol {
    
    /// Title attributes to use for button title labe.
    ///
    /// - Parameter text: Text to get attributes for.
    /// - Returns: Attributed string for text.
    func titleAttributedString(text: String) -> NSAttributedString
    
    /// Contains all properties to set in a button for its initial state.
    ///
    /// - Parameter button: Closure that returns button to stylize.
    func initialState(button: @escaping () -> UIButton)
    
    /// Contains all properties to set in a button for its normal state.
    ///
    /// - Parameter button: Closure that returns button to stylize.
    func normalState(button: @escaping () -> UIButton)
    
    /// Contains all properties to set in a button for its highlighed state.
    ///
    /// - Parameter button: Closure that returns button to stylize.
    func highlightedState(button: @escaping () -> UIButton)
    
    /// Contains all properties to set in a button for its inactive state.
    ///
    /// - Parameter button: Closure that returns button to stylize.
    func inactiveState(button: @escaping () -> UIButton)
}

//MARK: - TMButtonGradientStyleProtocol

protocol TMButtonGradientStyleProtocol {
    
    /// Gradiient colors to use in buttons gradient layer.
    ///
    /// - Returns: Array of CGColors.
    func gradientColors() -> [CGColor]
}

//MARK: - TMButtonStyleProtocol Extension

extension TMButtonStyleProtocol {
    
    /// Set up for a layers black shadow.
    ///
    /// - Parameters:
    ///   - layer: Layer to add shadow.
    ///   - shadowOpacity: Opacity of shadow.
    ///   - shadowRadius: Blur radius of shadow.
    ///   - shadowOffset: Offet of shadow.
    func enableShadow(for layer: CALayer, shadowOpacity: Float, shadowRadius: CGFloat, shadowOffset: CGSize) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
    }
    
    /// Removes shadow from layer by turning it's opacity to 0.
    ///
    /// - Parameter layer: Layer to remove shadow.
    func disableShadow(for layer: CALayer) {
        layer.shadowOpacity = 0
    }
}
