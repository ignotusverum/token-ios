//
//  TMAddCreditCardPaymentTheme.swift
//  consumer
//
//  Created by Gregory Sapienza on 3/10/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

/// Themes for TMNewPaymentViewController and cells.
///
/// - light: White background with dark text theme.
/// - dark: Black background with white text theme.
enum TMAddCreditCardPaymentTheme {
    case light
    case dark
    
    /// Background color of the view controller.
    ///
    /// - Returns: Color to use for the background.
    func backgroundColor() -> UIColor {
        switch self {
        case .light:
            return UIColor.TMGrayBackgroundColor
        case .dark:
            return UIColor.TMColorWithRGBFloat(29, green: 27, blue: 31, alpha: 1)
        }
    }
    
    /// Color of navigation items such as the title and nav bar buttons.
    ///
    /// - Returns: Color to use for navigation items.
    func navigationTintColor() -> UIColor {
        switch self {
        case .light:
            return UIColor.black
        case .dark:
            return UIColor.white
        }
    }
    
    /// Color of titles for payment type titles.
    ///
    /// - Returns: Colors to use for payment type titles within each cell.
    func titleColor() -> UIColor {
        switch self {
        case .light:
            return UIColor.TMColorWithRGBFloat(155, green: 155, blue: 155, alpha: 1)
        case .dark:
            return UIColor.TMColorWithRGBFloat(155, green: 155, blue: 155, alpha: 1)
        }
    }
    
    /// Color of text field text for payment types.
    ///
    /// - Returns: Colors to use for payment text field text within each cell.
    func textColor() -> UIColor {
        switch self {
        case .light:
            return UIColor.TMColorWithRGBFloat(20, green: 20, blue: 20, alpha: 1)
        case .dark:
            return UIColor.white
        }
    }
    
    /// Color of text field placeholder text for payment types.
    ///
    /// - Returns: Colors to use for payment text field placeholder text within each cell.
    func placeholderColor() -> UIColor {
        switch self {
        case .light:
            return UIColor.TMColorWithRGBFloat(155, green: 155, blue: 155, alpha: 0.5)
        case .dark:
            return UIColor.TMColorWithRGBFloat(74, green: 74, blue: 74, alpha: 1)
        }
    }
    
    /// Color to use for cell border.
    ///
    /// - Returns: Cell border color.
    func lineColor() -> UIColor {
        switch self {
        case .light:
            return UIColor.TMColorWithRGBFloat(74, green: 74, blue: 74, alpha: 0.1)
        case .dark:
            return UIColor.TMColorWithRGBFloat(74, green: 74, blue: 74, alpha: 1)
        }
    }
    
    /// Color of accessory views within cells that require them.
    ///
    /// - Returns: Color for an accessory view in certain cells.
    func accessoryColor() -> UIColor {
        switch self {
        case .light:
            return UIColor.TMColorWithRGBFloat(204, green: 204, blue: 204, alpha: 1)
        case .dark:
            return UIColor.TMColorWithRGBFloat(170, green: 170, blue: 170, alpha: 1)
        }
    }
    
    /// Keyboard appearance to use with payment text fields.
    ///
    /// - Returns: Keyboard appearance for payment text fields.
    func keyboardAppearance() -> UIKeyboardAppearance {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
