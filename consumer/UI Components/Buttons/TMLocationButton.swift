//
//  TMLocationButton.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/21/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import Foundation

enum ButtonLocations: String {
    case nyc = "NYC"
    case la = "LA"
    case sf = "SF"
    
    /// Copy
    func locationCopy()-> String {
        switch self {
        case .nyc:
            return "New York, NY"
        case .la:
            return "Los Angeles, CA"
        case .sf:
            return "San Francisco, CA"
        }
    }
    
    /// All locations
    static let allData: [ButtonLocations] = [.nyc, .la, .sf]
}

class TMLocationButton: UIButton {
    
    /// Location
    var location: ButtonLocations = .nyc {
        didSet {
            
            /// Font setup
            let attributedTitleSelected = NSAttributedString(string: location.rawValue, attributes: [NSFontAttributeName: UIFont.MalloryBook(12), NSForegroundColorAttributeName: UIColor.black])
            let attributedTitleUnSelected = NSAttributedString(string: location.rawValue, attributes: [NSFontAttributeName: UIFont.MalloryBook(12), NSForegroundColorAttributeName: UIColor.TMLightGrayPlaceholder])
            
            setAttributedTitle(attributedTitleSelected, for: .selected)
            setAttributedTitle(attributedTitleUnSelected, for: .normal)
        }
    }
}
