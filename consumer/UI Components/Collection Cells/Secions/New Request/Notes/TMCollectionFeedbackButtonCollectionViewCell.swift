//
//  TMCollectionFeedbackButtonCollectionViewCell.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/22/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

protocol TMCollectionFeedbackButtonCollectionViewCellProtocol {
    func feedbackButtonTapped()
}

class TMCollectionFeedbackButtonCollectionViewCell: UICollectionViewCell {
    var delegate: TMCollectionFeedbackButtonCollectionViewCellProtocol?
    
    fileprivate lazy var feedbackButton: UIButton = {
        let button = UIButton.button(style: .alternateBlack)
        
        button.setTitle("Send Feedback", for: .normal)
        button.addTarget(self, action: #selector(onFeedbackButton), for: .touchUpInside)
        
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(feedbackButton)
        
        feedbackButton.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints([
            NSLayoutConstraint(item: feedbackButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: feedbackButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: feedbackButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: feedbackButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 66)
            ])
    }
    
    func onFeedbackButton(_ sender: UIButton) {
        delegate?.feedbackButtonTapped()
    }
}
