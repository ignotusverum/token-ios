//
//  TMCartFeeTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 11/1/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMCartFeeTableViewCell: UITableViewCell {

    // Fee Object5
    var fee: TMFee?

    // Request Object
    var cart: TMCart?
    
    // Fee Title Label
    @IBOutlet weak var feeTitleLabel: UILabel!
    
    // Fee Price Label
    @IBOutlet weak var feePriceLabel: UILabel!
    
    var lastRow = 0
    var indexPath: IndexPath! {
        didSet {
         
            bottomDividerView.isHidden = indexPath.row != lastRow - 1
        }
    }
    
    // Dividers
    @IBOutlet weak var bottomDividerView: UIView!
    
    func setupCopy(cart: TMCart?, fee: TMFee?) {
        
        guard let fee = fee, let cart = cart else {
            return
        }

        let fontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 13.0 : 12.0
        
        let mainTitlePart = NSMutableAttributedString(string: fee.feeType.rawValue, attributes: [NSFontAttributeName : UIFont.MalloryBook(fontSize), NSForegroundColorAttributeName: UIColor.TMBlackColor, NSKernAttributeName: 1.0])
        
        if fee.feeType == .service {
            
            let feeFontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 10.0 : 9.0
            
            // Value attributed string
            let combinedPart = NSMutableAttributedString(string: " • ", attributes: [NSFontAttributeName : UIFont.MalloryBook(feeFontSize), NSForegroundColorAttributeName: UIColor.TMPinkishGray, NSKernAttributeName: 1.0])
            let percentagePart = NSMutableAttributedString(string: "\(cart.serviceFeePercentage)%", attributes: [NSFontAttributeName : UIFont.MalloryBook(fontSize), NSForegroundColorAttributeName: UIColor.TMPinkishGray, NSKernAttributeName: 1.0])
            
            combinedPart.append(percentagePart)
            mainTitlePart.append(combinedPart)
            
            feeTitleLabel.attributedText = mainTitlePart
        } else {
        
            feeTitleLabel.attributedText = mainTitlePart
        }
        
        feePriceLabel.text = String(format: "$%.2f", fee.value)
    }
}
