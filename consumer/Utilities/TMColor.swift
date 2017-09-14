//
//  TMColor.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/28/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func TMColorWithRGBFloat(_ red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)-> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    // MARK: - Gradient
    open class var firstGradientColor: UIColor {
        return UIColor.TMColorWithRGBFloat(174.0, green: 124.0, blue: 88.0, alpha: 1.0)
    }
    
    open class var secondGradientColor: UIColor {
        return UIColor.TMColorWithRGBFloat(243.0, green: 190.0, blue: 135.0, alpha: 1.0)
    }
    
    // MARK: - Colors
    
    open class var TMGoldColor: UIColor {
        return UIColor.TMColorWithRGBFloat(243.0, green: 190.0, blue: 135.0, alpha: 1.0)
    }
    
    open class var TMBlackColor: UIColor {
        return UIColor.TMColorWithRGBFloat(29.0, green: 27.0, blue: 31.0, alpha: 1.0)
    }
    
    open class var TMPhoneVerificationGrayColor: UIColor{
        return UIColor.TMColorWithRGBFloat(65.0, green: 62.0, blue: 67.0, alpha: 1.0)
    }
    
    open class var TMPhoneVerificationGoldColor: UIColor{
        return UIColor.TMColorWithRGBFloat(174.0, green: 124.0, blue: 88.0, alpha: 1.0)
    }
    
    open class var TMPhoneValidationHighlited: UIColor {
        return TMColorWithRGBFloat(48.0, green: 45.0, blue: 50.0, alpha: 1.0)
    }
    
    open class var TMPinkColor: UIColor {
        return TMColorWithRGBFloat(252.0, green: 203.0, blue: 232.0, alpha: 1.0)
    }
    
    open class var TMPinkishGray: UIColor {
        return TMColorWithRGBFloat(193.0, green: 193.0, blue: 193.0, alpha: 1.0)
    }
    
    open class var TMDarkPinkColor: UIColor {
        return TMColorWithRGBFloat(196.0, green: 138.0, blue: 136.0, alpha: 1.0)
    }
    
    open class var TMButtonColor: UIColor {
        return TMColorWithRGBFloat(249.0, green: 226.0, blue: 241.0, alpha: 1.0)
    }
    
    open class var TMGrayBackgroundColor: UIColor {
        return TMColorWithRGBFloat(249.0, green: 249.0, blue: 249.0, alpha: 1.0)
    }
    
    open class var TMErrorColor: UIColor {
        return TMColorWithRGBFloat(253.0, green: 115.0, blue: 97.0, alpha: 1.0)
    }
    
    // MARK: - Grays
    open class var TMLightGrayPlaceholder: UIColor {
        return TMColorWithRGBFloat(155.0, green: 155.0, blue: 155.0, alpha: 1.0)
    }
    
    open class var TMTitleBlackColor: UIColor {
        return TMColorWithRGBFloat(20.0, green: 20.0, blue: 20.0, alpha: 1.0)
    }
    
    open class var TMGrayPlaceholder: UIColor {
        return TMColorWithRGBFloat(74.0, green: 74.0, blue: 74.0, alpha: 1.0)
    }
    
    open class var TMGrayCell: UIColor {
        return TMColorWithRGBFloat(151.0, green: 151.0, blue: 151.0, alpha: 1.0)
    }
    
    open class var TMGrayColor: UIColor {
        return TMColorWithRGBFloat(215.0, green: 215.0, blue: 215.0, alpha: 1.0)
    }
    
    open class var TMGrayDisabledButtonColor: UIColor {
        return TMColorWithRGBFloat(170.0, green: 170.0, blue: 170.0, alpha: 0.3 )
    }
    
    open class var TMLightGrayColor: UIColor {
        return TMColorWithRGBFloat(210.0, green: 210.0, blue: 210.0, alpha: 0.15)
    }
    
    // MARK: -
    
    open class var TMContactsBackgroundColor: UIColor {
        return TMColorWithRGBFloat(248.0, green: 248.0, blue: 248.0, alpha: 1.0)
    }
    
    open class var TMContactsTextColor: UIColor {
        return TMColorWithRGBFloat(204.0, green: 204.0, blue: 204.0, alpha: 1.0)
    }
    
    // MARK: -
    
    open class var TMMenuBackgroundColor: UIColor {
        return TMColorWithRGBFloat(248.0, green: 248.0, blue: 248.0, alpha: 1.0)
    }
    
    open class var TMMenuCellColor: UIColor {
        return TMColorWithRGBFloat(248.0, green: 248.0, blue: 248.0, alpha: 1.0)
    }
    
    open class var TMMenuCellSelectedColor: UIColor {
        return TMColorWithRGBFloat(240.0, green: 240.0, blue: 240.0, alpha: 1.0)
    }
    
    open class var TMMenuCellSelectionHeaderColor: UIColor {
        return TMColorWithRGBFloat(235.0, green: 235.0, blue: 235.0, alpha: 1.0)
    }
    
    // MARK: - request status
    
    open class var TMRequestStatusViewOutlineColor: UIColor {
        return TMColorWithRGBFloat(74.0, green: 71.0, blue: 75.0, alpha: 1.0)
    }
    
    open class var TMRequestStatusViewTextColor: UIColor {
        return TMColorWithRGBFloat(142.0, green: 141.0, blue: 143.0, alpha: 1.0)
    }
    
    open class var greyishBrown: UIColor {
        return TMColorWithRGBFloat(74.0, green: 74.0, blue: 74.0, alpha: 1.0)
    }
    
    // MARK: - Button Colors
    @nonobjc
    open class var goldGradientColors: [CGColor] {
        let color1 = UIColor(colorLiteralRed: 174/255, green: 124/255, blue: 88/255, alpha: 1).cgColor
        let color2 = UIColor(colorLiteralRed: 243/255, green: 190/255, blue: 135/255, alpha: 1).cgColor
        
        return [color1, color2]
    }
    
    /// Dark purple
    open class var darkPurple: UIColor {
        return TMColorWithRGBFloat(61.0, green: 37.0, blue: 50.0, alpha: 1)
    }
    
    /// Dark pink normal
    open class var darkPinkNormal: UIColor {
        return TMColorWithRGBFloat(126, green: 80, blue: 95, alpha: 1)
    }
    
    /// Dark pink highlighted
    open class var darkPinkHighlighted: UIColor {
        return TMColorWithRGBFloat(55, green: 34, blue: 41, alpha: 1)
    }
    
    /// Dark pink inactive
    open class var darkPinkInactive: UIColor {
        return TMColorWithRGBFloat(29, green: 29, blue: 29, alpha: 1)
    }
    
    /// Black normal
    open class var blackNormal: UIColor {
        return TMColorWithRGBFloat(29, green: 29, blue: 29, alpha: 1)
    }
    
    // MARK: - Feedback colors
    open class var feedbackLove: UIColor {
        return TMColorWithRGBFloat(136, green: 224, blue: 100, alpha: 1)
    }
    
    open class var feedbackLike: UIColor {
        return TMColorWithRGBFloat(113, green: 198, blue: 113, alpha: 1)
    }
    
    open class var feedbackNeutral: UIColor {
        return TMColorWithRGBFloat(231, green: 231, blue: 231, alpha: 1)
    }
    
    open class var feedbackNegative: UIColor {
        return TMColorWithRGBFloat(225, green: 130, blue: 113, alpha: 1)
    }
    
    open class var feedbackRemove: UIColor {
        return TMColorWithRGBFloat(225, green: 103, blue: 93, alpha: 1)
    }
    
    open class var feedbackInactive: UIColor {
        return TMColorWithRGBFloat(216, green: 216, blue: 216, alpha: 1)
    }
}
