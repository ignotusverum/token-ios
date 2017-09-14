
//
//  TMItemIndexCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/5/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import PromiseKit

protocol TMItemIndexCollectionViewCellDelegate {
    
    func feedbackView(_ feedbackView: TMFeedbackContainerRatingView, ratedItem item: TMItem, feedback: TMFeedbackType)
}

class TMItemIndexCollectionViewCell: UICollectionViewCell, TMItemIndexCellLayoutProtocol {
    
    var delegate: TMItemIndexCollectionViewCellDelegate?
    
    var separatorView: UIView = {
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.TMGrayBackgroundColor
        
        return separatorView
    }()
    
    lazy var feedbackView: TMFeedbackContainerRatingView = {
        
        return TMFeedbackContainerRatingView(item: self.item!, containerView: self, feedbackSelected: { type, container in
            
            self.delegate?.feedbackView(container, ratedItem: self.item!, feedback: type)
        })
    }()
    
    // Item
    var item: TMItem? {
        didSet {
            
            layoutSubviews()
            
            guard let item = item else {
                return
            }
            
            feedbackView.item = item
            feedbackView.reloadFeedback()
        }
    }
    
    // Image View
    var imageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    // Title Label
    var titleLabel: UILabel = {
        
        let label = UILabel()
        label.numberOfLines = 0
        
        return label
    }()
    
    // Price Label
    var priceLabel: UILabel = {
        
        let label = UILabel()
        label.numberOfLines = 1
        
        return label
    }()
    
    // MARK: - Private
    private func customInit() {
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(priceLabel)
        addSubview(separatorView)
        
        backgroundColor = .white
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// Safety checks
        guard let item = item, let product = item.product else {
            
            if let productID = self.item?.productID {
                TMProductAdapter.fetch(productID: productID).then { response-> Void in
                    
                    self.item?.product = response
                    self.setNeedsLayout()
                    
                    }.catch { error in
                        print(error)
                }
            }
            
            return
        }
        
        // Product price
        priceLabel.attributedText = price(product.copyPriceString)
        
        // Set Title
        guard let titleCopy = item.title else {
            return
        }
        
        // Item Title
        titleLabel.attributedText = title(titleCopy)
        
        /// Feedback setup
        addSubview(feedbackView)
        
        // Layout
        var layout = TMItemIndexCellLayout(image: imageView, title: titleLabel, price: priceLabel, separator: separatorView, feedback: feedbackView)
        layout.layout(in: bounds)
        
        // Product Image
        if let imageURL = product.primaryImage?.imageURL {
            
            // Download Item image
            imageView.downloadImageFrom(link: imageURL, contentMode: .scaleAspectFit)
        }
    }
    
    // MARK: - Utilities
    /// Generates title for item.
    ///
    /// - Parameter text: Text to use to set attributes.
    /// - Returns: Attributed string with provided text.
    private func title(_ title: String) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 5.0
        
        var fontSize: CGFloat = DeviceType.IS_IPHONE_6 ? 11.0 : 13.0
        fontSize = DeviceType.IS_IPHONE_5 ? 9.0 : fontSize
        
        let attributedString = NSAttributedString(string: title, attributes: [NSFontAttributeName: UIFont.MalloryMedium(fontSize), NSForegroundColorAttributeName: UIColor.TMGrayPlaceholder, NSParagraphStyleAttributeName : paragraphStyle])
        
        return attributedString
    }
    
    /// Generates status label attributes.
    ///
    /// - Parameter text: Text to use to set attributes.
    /// - Returns: Attributed string with provided text.
    private func price(_ price: String) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        var fontSize: CGFloat = DeviceType.IS_IPHONE_6 ? 10.0 : 12.0
        fontSize = DeviceType.IS_IPHONE_5 ? 8.0 : fontSize
        
        let attributedString = NSMutableAttributedString(string: price, attributes: [NSFontAttributeName: UIFont.MalloryBook(fontSize), NSForegroundColorAttributeName: UIColor.TMGrayCell, NSKernAttributeName: 0.2, NSParagraphStyleAttributeName : paragraphStyle])
        
        return attributedString
    }
}
