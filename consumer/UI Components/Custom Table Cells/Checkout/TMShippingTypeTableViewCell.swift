//
//  TMShippingTypeTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/2/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMShippingTypeTableViewCell: UITableViewCell {

    /// Cart object
    /// Used to detect if it's premium wrapping or not
    var shippingType: TMShippingType? {
        didSet {
            
            guard let shippingType = shippingType else {
                return
            }
            
            /// Shipping type setup
            titleLabel?.attributedText = generateTitle(shippingType.title)
            
            /// Shipping type setup
            wrappingType = shippingType.wrappingType
            
            /// Shipping type image setup
            if let shippingTypeString = shippingType.imageString, let shippingTypeURL = URL(string: shippingTypeString) {
             
                shippingTypeImageView?.af_setImage(withURL: shippingTypeURL)
            }
            else {
                
                shippingTypeImageView?.image = UIImage()
            }
        }
    }
    
    var wrappingType: WrappingType = .wrapped {
        didSet {
            
            // Setup UI based on wrapping selection
            if wrappingType == .wrapped {
                
                descriptionLabel?.attributedText = generateTwoPartDescription(first: generateDescription(shippingType?.displayPrice ?? ""), second: "Remove")
            }
            else {
                
                descriptionLabel?.attributedText = generateUnderlineText(string: "Add Gift Wrap", color: UIColor.TMLightGrayPlaceholder)
            }
        }
    }
    
    /// Product image view
    @IBOutlet weak var shippingTypeImageView: UIImageView?
    
    /// Product title label
    @IBOutlet weak var titleLabel: UILabel?
    
    /// Product price label
    @IBOutlet weak var descriptionLabel: UILabel?
    
    // MARK: - Utilities
    /// Generates NSMutableAttributedString for cell title
    ///
    /// - Parameter string: string to transform
    private func generateTitle(_ string: String?)-> NSMutableAttributedString {
        
        guard let string = string else {
            return NSMutableAttributedString(string: "")
        }
        
        let fontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 15.0 : 14.0
        
        let attributedString = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName: UIFont.ActaMedium(fontSize), NSForegroundColorAttributeName: UIColor.TMBlackColor])
        
        return attributedString
    }
    
    /// Generate description attributed string
    ///
    /// - Parameter cartItem: cart item core data object
    private func generateDescription(_ string: String?)-> NSMutableAttributedString {
        
        guard let string = string else {
            return NSMutableAttributedString(string: "")
        }
        
        let fontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 13.0 : 12.0
        
        let attributedString = NSMutableAttributedString(string: "\(string)", attributes: [NSFontAttributeName: UIFont.MalloryBook(fontSize), NSForegroundColorAttributeName: UIColor.TMLightGrayPlaceholder, NSKernAttributeName: 1.0])
        
        return attributedString
    }
    
    /// Generates two part description
    private func generateTwoPartDescription(first: NSMutableAttributedString, second: String)-> NSMutableAttributedString {
        
        let fontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 10.0 : 11.0
        
        let middlePart = NSMutableAttributedString(string: "  •  ", attributes: [NSFontAttributeName : UIFont.MalloryBook(fontSize), NSForegroundColorAttributeName: UIColor.TMPinkishGray, NSKernAttributeName: 1.0])
        let underlinePart = generateUnderlineText(string: second)
        
        first.append(middlePart)
        first.append(underlinePart)
        
        return first
    }
    
    private func generateUnderlineText(string: String, color: UIColor = UIColor.TMPinkishGray)-> NSMutableAttributedString {
        
        let fontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 12.0 : 13.0
        
        let result = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName : UIFont.MalloryBook(fontSize), NSForegroundColorAttributeName: color, NSKernAttributeName: 1.0, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        
        return result
    }
}
