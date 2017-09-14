//
//  TMFeedbackButtonProtocol.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/28/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import EZSwiftExtensions

/// Rating buttons feedback types
enum TMFeedbackType: Int {
    
    case inactive = 0
    case remove
    case negative
    case neutral
    case positive
    case love
    
    /// Copies for overlay layer
    static let allCopies = ["", "Remove", "Don't like", "It's Ok", "Like it", "Love it!"]
    
    /// Colors for fill color + overlay layer
    static let allColors = [UIColor.feedbackInactive, UIColor.feedbackRemove, UIColor.feedbackNegative, UIColor.feedbackNeutral, UIColor.feedbackLike, UIColor.feedbackLove]
}

struct TMFeedbackModel {
    
    /// Item - used to define active / inactive state
    var item: TMItem
    
    /// Type of feedback
    var feedbackType: TMFeedbackType
    
    /// Timing function
    var timingFunction: CAMediaTimingFunction
    
    /// Overall copy
    var overallCopy: String
    
    /// Is active
    var isActive: Bool = false {
        didSet {
            
            /// Change Colors
            backgroundShape.borderWidth = 1
            backgroundShape.strokeColor = stateStrokeColor.cgColor
            backgroundShape.fillColor = stateFillColor.cgColor
        }
    }
    
    /// Main background shape
    var backgroundShape: CAShapeLayer = CAShapeLayer()
    
    /// Layers for custom animations - runFeedbackAnimationFor:
    var animationLayers: [CAShapeLayer] = []
    
    /// Overlay layer that presented when button tapped
    var overlayLayer: CAShapeLayer = CAShapeLayer()
    
    /// Main backgdound color
    var fillColor: UIColor
    
    /// Initialization
    init (feedbackType: TMFeedbackType, item: TMItem, timingFunction: CAMediaTimingFunction) {
        
        self.item = item
        self.feedbackType = feedbackType
        
        /// Set default values
        self.overallCopy = TMFeedbackType.allCopies[feedbackType.rawValue]
        if self.overallCopy.contains("____") {
            let name = item.recommendation?.request?.contact?.availableName ?? ""
            self.overallCopy = self.overallCopy.replacingOccurrences(of: "____", with: name)
        }
        
        /// Set default color
        self.fillColor = TMFeedbackType.allColors[feedbackType.rawValue]
        
        /// Timing function for animation
        self.timingFunction = timingFunction
    }
    
    /// Stroke color for main background layer
    var stateStrokeColor: UIColor {
        return isActive ? UIColor.clear : UIColor.feedbackInactive
    }
    
    /// Active Color
    var animationStrokeColor: UIColor {
        return isActive ? UIColor.black : UIColor.feedbackInactive
    }
    
    /// Fill color for main background layer
    var stateFillColor: UIColor {
        return isActive ? fillColor : UIColor.clear
    }
    
    /// Generate overlay layer
    ///
    /// - Parameters:
    ///   - frame: Frame for display
    ///   - color: Background color
    ///   - copy: Copy for Overlay
    /// - Returns: Overlay layer
    func generateOverlayLayer(frame: CGRect, color: UIColor, copy: String, textColor: UIColor = UIColor.white)-> CAShapeLayer {
        return TMFeedbackOverlayView.drawOverlayView(frame: frame, color: color, copy: copy, textColor: textColor)
    }
}

class TMFeedbackRatingView: UIView, TMFeedbackButtonProtocol {
    
    /// Called when feedback selected
    var feedbackSelected: (TMFeedbackType, TMFeedbackContainerRatingView)-> Void
    
    /// Runs animation for specific layer
    func runFeedbackAnimationFor(isAnimated: Bool, layer: CAShapeLayer) {}
    
    /// Feedback model for UI & datasource
    var feedbackModel: TMFeedbackModel
    
    /// Container View for adjusting frames
    var containerView: TMFeedbackContainerRatingView
    
    // MARK: - Initialization
    init(feedbackModel: TMFeedbackModel, containerView: TMFeedbackContainerRatingView, frame: CGRect, feedbackSelected: @escaping (TMFeedbackType, TMFeedbackContainerRatingView)-> Void) {
        
        self.containerView = containerView
        self.feedbackModel = feedbackModel
        self.feedbackSelected = feedbackSelected
        
        super.init(frame: frame)
        
        setupView(containerView: containerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Do not do this TMNegativeFeedbackView")
    }
    
    /// Setup up container
    func setupView(containerView: UIView) {
        
        /// Generate overlay layer
        let overlayWidth = frame.width
        feedbackModel.overlayLayer = feedbackModel.generateOverlayLayer(frame: CGRect(x: centerX - overlayWidth/2, y: -60 / 1.2, w: overlayWidth, h: 56), color: feedbackModel.fillColor, copy: feedbackModel.overallCopy)
        
        /// Adding view as subview
        containerView.addSubviewWithCheck(self)
    }
    
    /// Track of touch event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let cart = feedbackModel.item.recommendation?.request?.cart else {
            return
        }
        
        if feedbackModel.item.feedbackType != feedbackModel.feedbackType {
            if touches.first != nil && cart.isCheckoutAvaliable {
                /// Current view pressed, change state
                feedbackModel.isActive = !feedbackModel.isActive
                
                /// Call selected closure
                feedbackSelected(feedbackModel.feedbackType, containerView)
                
                /// Run animation for animation layers
                /// Show overlay layer
                presentOverlay(isActive: feedbackModel.isActive, layer: feedbackModel.overlayLayer)
                
                for layer in feedbackModel.animationLayers {
                    
                    runFeedbackAnimationFor(isAnimated: feedbackModel.isActive, layer: layer)
                }
                
                return
            }
        }
    }
    
    /// Same logic as in reloadData()
    func updateState() {
        
        /// Check which one is active
        feedbackModel.isActive = feedbackModel.item.feedbackType == feedbackModel.feedbackType
        for layer in feedbackModel.animationLayers {
            runFeedbackAnimationFor(isAnimated: false, layer: layer)
        }
        
        /// Hide not active overlay layers, if presented
        if !feedbackModel.isActive {
            
            presentOverlay(isActive: false, layer: feedbackModel.overlayLayer)
        }
    }
}

protocol TMFeedbackButtonProtocol {

    /// Feedback model
    var feedbackModel: TMFeedbackModel { get set }
    
    /// Runs animation for specific layer
    func runFeedbackAnimationFor(isAnimated: Bool, layer: CAShapeLayer)
}

extension TMFeedbackButtonProtocol {
    
    /// Present overlay layer with animation
    ///
    /// - Parameters:
    ///   - isActive: state for animation
    ///   - layer: overlay layer
    ///   - recurringAnimation: parameter for recustion call
    func presentOverlay(isActive: Bool, layer: CAShapeLayer, recurringAnimation: Bool = false) {
        
        if isActive {
            /// Add presentation animation
            let fadeAnimation = CAKeyframeAnimation(keyPath:"opacity")
            fadeAnimation.beginTime = 0
            fadeAnimation.duration = 1
            fadeAnimation.keyTimes = [0, NSNumber(value: 1/8), NSNumber(value: 5/8), 1]
            fadeAnimation.isRemovedOnCompletion = false
            fadeAnimation.fillMode = kCAFillModeForwards
            layer.add(fadeAnimation, forKey:"animateOpacity")
            
            /// Animation values based on status
            if !isActive || recurringAnimation {
                
                fadeAnimation.values = [1.0, 0.0]
                layer.opacity = 0.0
            }
            else {
                
                fadeAnimation.values = [0.0, 1.0]
                layer.opacity = 1.0
                
                /// Run same animation but for fade-out
                ez.runThisAfterDelay(seconds: 1.0, after: {
                    self.presentOverlay(isActive: isActive, layer: layer, recurringAnimation: true)
                })
            }
        }
        else {
            
            layer.opacity = 0
        }
    }
}
