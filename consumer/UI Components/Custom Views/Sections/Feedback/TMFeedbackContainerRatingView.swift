//
//  TMFeedbackContainerRatingView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/24/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMFeedbackContainerRatingView: UIView, TMFeedbackRatingLayoutProtocol {
    
    /// Faces views
    lazy var ratingViews: [TMFeedbackRatingView] = {
        
        let facesTimingFunction = CAMediaTimingFunction(controlPoints: 1, 0.01, 0, 1.01)
        
        /// Remove feedback model
        let removeFeedback = TMFeedbackModel(feedbackType: .remove, item: self.item, timingFunction: facesTimingFunction)
        
        /// Negative feedback model
        let negativeFeedback = TMFeedbackModel(feedbackType: .negative, item: self.item, timingFunction: facesTimingFunction)
        
        /// Neutral feedback model
        let neutralFeedback = TMFeedbackModel(feedbackType: .neutral, item: self.item, timingFunction: facesTimingFunction)
        
        /// Positive feedback model
        let positiveFeedback = TMFeedbackModel(feedbackType: .positive, item: self.item, timingFunction: facesTimingFunction)
        
        /// Love feedback model
        let loveTimeFunction = CAMediaTimingFunction(controlPoints: 1, 0.01, 0, 1.01)
        let loveFeedback = TMFeedbackModel(feedbackType: .love, item: self.item, timingFunction: loveTimeFunction)
        
        /// Rect for feedbackViews
        let feedbackModels = [removeFeedback, negativeFeedback, neutralFeedback, positiveFeedback, loveFeedback]
        let feedbackRect = CGRect(x: 0, y: 0, w: self.containerView.frame.width/CGFloat(feedbackModels.count), h: 60)
        
        /// Feedback Views
        /// Remove View
        let removeFeedbackView = TMRemoveFeedbackView(feedbackModel: removeFeedback, containerView: self, frame: feedbackRect, feedbackSelected: self.feedbackSelected)
        
        /// Negative View
        let negativeFeedbackView = TMNegativeFeedbackView(feedbackModel: negativeFeedback, containerView: self, frame: feedbackRect, feedbackSelected: self.feedbackSelected)
        
        /// Neutral View
        let neutralFeedbackView = TMNeutralFeedbackView(feedbackModel: neutralFeedback, containerView: self, frame: feedbackRect, feedbackSelected: self.feedbackSelected)
        
        /// Positive View
        let positiveFeedbackView = TMPositiveFeedbackView(feedbackModel: positiveFeedback, containerView: self, frame: feedbackRect, feedbackSelected: self.feedbackSelected)
        
        /// Love View
        let loveFeedbackView = TMLoveFeedbackView(feedbackModel: loveFeedback, containerView: self, frame: feedbackRect, feedbackSelected: self.feedbackSelected)
        
        let resultFeedbackViews = [removeFeedbackView, negativeFeedbackView, neutralFeedbackView, positiveFeedbackView, loveFeedbackView]
        
        /// Result feedback views
        return resultFeedbackViews
    }()
    
    /// Item
    var item: TMItem
    
    /// Container View
    var containerView: UIView
    
    /// Called when feedback selected
    private var feedbackSelected: (TMFeedbackType, TMFeedbackContainerRatingView)-> Void
    
    /// Rating for UI
    private var rating: Int {
        
        /// Neutral by default
        return item.rating?.intValue ?? 2
    }

    // MARK:  - Initialization
    init(item: TMItem, containerView: UIView, feedbackSelected: @escaping (TMFeedbackType, TMFeedbackContainerRatingView)-> Void) {
        self.item = item
        self.containerView = containerView
        
        /// Feedback selection handling
        self.feedbackSelected = feedbackSelected
        
        super.init(frame: containerView.bounds)
        
        layoutSubviews()
        reloadFeedback()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// layout check
        var layout = TMFeedbackRatingLayout(views: ratingViews)
        layout.layout(in: bounds)
    }
    
    /// Reload  data
    func reloadFeedback() {
        
        let _ = ratingViews.map { $0.feedbackModel.item = self.item }
        let _ = ratingViews.map { $0.updateState() }
    }
}
