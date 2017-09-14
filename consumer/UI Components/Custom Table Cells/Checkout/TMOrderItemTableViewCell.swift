//
//  TMOrderItemTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/2/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMOrderItemTableViewCell: UITableViewCell {

    var cartItem: TMCartItem? {
        didSet {
            
            guard let product = cartItem?.product else {
                return
            }
            
            // Product image setup
            if let imageURL = product.primaryImage?.imageURL {
                
                productImageView?.af_setImage(withURL: imageURL)
            }
            
            // Product title
            titleLabel?.attributedText = generateTitle(product.title)
            
            // Product price
            priceLabel?.attributedText = generatePrice(product.price?.stringValue)
        }
    }
    
    /// Product image view
    @IBOutlet weak var productImageView: UIImageView?
    
    /// Product title label
    @IBOutlet weak var titleLabel: UILabel?
    
    /// Product price label
    @IBOutlet weak var priceLabel: UILabel?
    
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
    private func generatePrice(_ string: String?)-> NSMutableAttributedString {
        
        guard let string = string else {
            return NSMutableAttributedString(string: "")
        }
        
        let fontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 13.0 : 12.0
        
        let attributedString = NSMutableAttributedString(string: "$\(string)", attributes: [NSFontAttributeName: UIFont.MalloryBook(fontSize), NSForegroundColorAttributeName: UIColor.TMLightGrayPlaceholder, NSKernAttributeName: 1.0])
        
        return attributedString
    }
}
