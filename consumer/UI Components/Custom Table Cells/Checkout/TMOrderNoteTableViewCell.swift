//
//  TMOrderNoteTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/2/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMOrderNoteTableViewCell: UITableViewCell {

    /// Note database object
    var note: TMCartLabel? {
        didSet {
            
            guard let note = note else {
                return
            }
            
            /// Set Title label
            titleLabel?.attributedText = generateTitle(to: note.to, from: note.from)
            
            /// Set Description label
            descriptionLabel?.attributedText = generateDetails(note: note.note)
        }
    }
    
    /// To note label
    @IBOutlet weak var titleLabel: UILabel?
    
    // Details label
    @IBOutlet weak var descriptionLabel: UILabel?
    
    
    // MARK: - Utilities
    private func generateTitle(to: String?, from: String?)-> NSAttributedString {
        
        guard let to = to, let from = from else {
            return NSAttributedString(string: "")
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
    
        let fontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 15.0 : 14.0
        
        let attributedString = NSAttributedString(string: "To: \(to)\nFrom: \(from)", attributes: [NSFontAttributeName: UIFont.ActaMedium(fontSize), NSForegroundColorAttributeName: UIColor.TMBlackColor, NSKernAttributeName: 0.4, NSParagraphStyleAttributeName : paragraphStyle])
        
        return attributedString
    }
    
    private func generateDetails(note: String?)-> NSAttributedString {
        
        guard let note = note else {
            return NSAttributedString(string: "")
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        
        let fontSize: CGFloat = DeviceType.IS_IPHONE_6P ? 13.0 : 12.0
        
        let attributedString = NSAttributedString(string: note, attributes: [NSFontAttributeName: UIFont.MalloryBook(fontSize), NSForegroundColorAttributeName: UIColor.TMLightGrayPlaceholder, NSKernAttributeName: 1.0, NSParagraphStyleAttributeName : paragraphStyle])
        
        return attributedString
    }
}
