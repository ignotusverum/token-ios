//
//  TMNavigationTheme.swift
//  consumer
//
//  Created by Gregory Sapienza on 4/10/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

enum NavigationTheme {
    case gray
    case hidden
    
    var barTintColor: UIColor {
        switch self {
        case .gray:
            return .TMGrayBackgroundColor
        case .hidden:
            return .clear
        }
    }
    
    var titleTextAttributes: [String: NSObject]? {
        switch self {
        case .gray:
            return [NSForegroundColorAttributeName: UIColor.black]
        case .hidden:
            return nil
        }
    }
    
    var defaultBackgroundImage: UIImage? {
        switch self {
        case .gray:
            return UIImage()
        case .hidden:
            return UIImage()
        }
    }
    
    var isTranslucent: Bool {
        switch self {
        case .gray:
            return false
        case .hidden:
            return true
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .gray:
            return .TMGrayBackgroundColor
        case .hidden:
            return .clear
        }
    }
    
    var shadowImage: UIImage {
        switch self {
        case .gray:
            return UIImage()
        case .hidden:
            return UIImage()
        }
    }
}

extension UINavigationBar {
    func applyTheme(navigationTheme: NavigationTheme) {
        barTintColor = navigationTheme.barTintColor
        setBackgroundImage(navigationTheme.defaultBackgroundImage, for: .default)
        titleTextAttributes = navigationTheme.titleTextAttributes
        isTranslucent = navigationTheme.isTranslucent
        backgroundColor = navigationTheme.backgroundColor
        shadowImage = navigationTheme.shadowImage
    }
}
