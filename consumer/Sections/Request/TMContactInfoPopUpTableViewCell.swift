//
//  TMContactInfoPopUpTableViewCell.swift
//  consumer
//
//  Created by Gregory Sapienza on 4/26/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMContactInfoPopUpTableViewCell: UITableViewCell {

    lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var contentTextLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.font = UIFont.ActaBook(16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //---Content Image View---//
        
        addSubview(contentImageView)
        
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            NSLayoutConstraint(item: contentImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: contentImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: contentImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: contentImageView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.2, constant: 0)
            ])
        
        //---Content Text Label---//
        
        addSubview(contentTextLabel)
        
        contentTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            NSLayoutConstraint(item: contentTextLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentTextLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentTextLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: contentTextLabel, attribute: .leading, relatedBy: .equal, toItem: contentImageView, attribute: .trailing, multiplier: 1, constant: 30)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setContentLabelText(text: String) {
        let attributedText = NSMutableAttributedString(string: text)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, text.length))
        
        contentTextLabel.attributedText = attributedText
        
        contentTextLabel.lineBreakMode = .byTruncatingTail //This needs to be here to autoshrink the font with attributed text set.
    }
}
