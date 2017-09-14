//
//  TMItemDetailsFeedbackCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/30/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import CoreStore

protocol TMItemDetailsFeedbackCollectionViewCellDelegate {
    
    func feedbackView(_ feedbackView: TMFeedbackContainerRatingView, ratedItem item: TMItem, feedback: TMFeedbackType)
}

class TMItemDetailsFeedbackCollectionViewCell: UICollectionViewCell, TMItemDetailsFeedbackLayoutProtocol {
    
    var delegate: TMItemDetailsFeedbackCollectionViewCellDelegate?
    
    // Item
    var item: TMItem? {
        didSet {
            
            guard let item = item else {
                return
            }
            
            feedbackView.item = item
            
            /// Reload when set
            feedbackView.reloadFeedback()
        }
    }
    
    /// Separator on top 
    var separatorView: UIView = {
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.TMGrayBackgroundColor
        
        return separatorView
    }()
    
    /// Feedback View
    lazy var feedbackView: TMFeedbackContainerRatingView = {
        
        return TMFeedbackContainerRatingView(item: self.item!, containerView: self, feedbackSelected: { type, container in
            
            self.delegate?.feedbackView(container, ratedItem: self.item!, feedback: type)
        })
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard item != nil else {
            return
        }
        
        customInit()
        
        // Layout
        var layout = TMItemDetailsFeedbackLayout(separator: separatorView, feedback: feedbackView)
        layout.layout(in: bounds)
    }
    
    // MARK: - Private
    private func customInit() {
        
        addSubview(separatorView)
        addSubview(feedbackView)
        
        backgroundColor = .white
    }
}
