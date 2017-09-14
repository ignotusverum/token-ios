//
//  TMFont.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/29/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

let TMDefaultFontSize: CGFloat = 14.0
let TMDefaultFont5Size: CGFloat = 12.0
let TMDefaultFont6pSize: CGFloat = 17.0

import EZSwiftExtensions

extension UIFont {

    static var defaultFontSize: CGFloat {
        
        var defaultValue: CGFloat = 14.0
        
        if DeviceType.IS_IPHONE_5 {
            defaultValue = TMDefaultFont5Size
        }
        else if DeviceType.IS_IPHONE_6P {
            defaultValue = TMDefaultFont6pSize
        }
        
        return defaultValue
    }
    
    static var titleSpacing: CGFloat {
        
        var defaultValue: CGFloat = 1.2
        
        if DeviceType.IS_IPHONE_5 {
            defaultValue = 0.6
        }
        else if DeviceType.IS_IPHONE_6P {
            defaultValue = 1.8
        }
        
        return defaultValue
    }
    
    static var titleFont: CGFloat {
        
        var defaultValue: CGFloat = 15.0
        
        if DeviceType.IS_IPHONE_5 {
            defaultValue = 12.0
        }
        else if DeviceType.IS_IPHONE_6P {
            defaultValue = 17.0
        }
        
        return defaultValue
    }
    
    static func MalloryBook(_ size: CGFloat = defaultFontSize)-> UIFont {
        return UIFont(name: "Mallory-Book", size: size)!
    }
    
    static func MalloryBold(_ size: CGFloat = defaultFontSize)-> UIFont {
        return UIFont(name: "Mallory-Bold", size: size)!
    }
    
    static func MalloryMedium(_ size: CGFloat = defaultFontSize)-> UIFont {
        return UIFont(name: "MalloryMP-Medium", size: size)!
    }
    
    static func ActaMedium(_ size: CGFloat = defaultFontSize)-> UIFont {
        return UIFont(name: "Acta-Medium", size: size)!
    }
    
    static func ActaBold(_ size: CGFloat = defaultFontSize)-> UIFont {
        return UIFont(name: "Acta-Bold", size: size)!
    }
    
    static func MalloryExtraLight(_ size: CGFloat = defaultFontSize)-> UIFont {
        return UIFont(name: "Mallory-ExtraLight", size: size)!
    }
    
    static func MalloryLight(_ size: CGFloat = defaultFontSize)-> UIFont {
        return UIFont(name: "Mallory-ExtraLight", size: size)!
    }
    
    static func ActaBookItalic(_ size: CGFloat = defaultFontSize)-> UIFont {
        return UIFont(name: "Acta-BookItalic", size: size)!
    }
    
    static func ActaBook(_ size: CGFloat = defaultFontSize)-> UIFont {
        return UIFont(name: "Acta-Book", size: size)!
    }
    
    static func mallotyLight(_ size: CGFloat = defaultFontSize)-> UIFont {
        return UIFont(name: "Mallory-Light", size: size)!
    }
}
