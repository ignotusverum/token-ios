//
//  TMLoveFeedbackView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/29/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class TMRemoveFeedbackView: TMFeedbackRatingView {
    
    override func setupView(containerView: UIView) {
        
        /// Adding view as subview
        super.setupView(containerView: containerView)
        
        /// Draw face
        drawFace()
    }
    
    // MARK: - Utilities
    /// Draw Face
    func drawFace(frame: CGRect = CGRect(x: 0, y: 0, width: 23, height: 23)) {
    
        // This non-generic function dramatically improves compilation times of complex expressions.
        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }
        
        //// Subframes
        let remove: CGRect = CGRect(x: centerX - frame.width/2, y: frame.minY + self.frame.height/2 - frame.height/2, width: frame.width, height: frame.height)
        
        //// Clip Clip 2
        let clip2Path = UIBezierPath()
        clip2Path.move(to: CGPoint(x: remove.minX + 12.5, y: remove.minY + 25))
        clip2Path.addCurve(to: CGPoint(x: remove.minX + 25, y: remove.minY + 12.5), controlPoint1: CGPoint(x: remove.minX + 19.4, y: remove.minY + 25), controlPoint2: CGPoint(x: remove.minX + 25, y: remove.minY + 19.4))
        clip2Path.addCurve(to: CGPoint(x: remove.minX + 12.5, y: remove.minY), controlPoint1: CGPoint(x: remove.minX + 25, y: remove.minY + 5.6), controlPoint2: CGPoint(x: remove.minX + 19.4, y: remove.minY))
        clip2Path.addCurve(to: CGPoint(x: remove.minX, y: remove.minY + 12.5), controlPoint1: CGPoint(x: remove.minX + 5.6, y: remove.minY), controlPoint2: CGPoint(x: remove.minX, y: remove.minY + 5.6))
        clip2Path.addCurve(to: CGPoint(x: remove.minX + 12.5, y: remove.minY + 25), controlPoint1: CGPoint(x: remove.minX, y: remove.minY + 19.4), controlPoint2: CGPoint(x: remove.minX + 5.6, y: remove.minY + 25))
        clip2Path.usesEvenOddFillRule = true
        
        let clipLayer = CAShapeLayer()
        clipLayer.path = clip2Path.cgPath
        clipLayer.fillColor = UIColor.clear.cgColor
        
        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: remove.minX + 0.50000 * remove.width, y: remove.minY + 1.00000 * remove.height))
        bezier4Path.addCurve(to: CGPoint(x: remove.minX + 1.00000 * remove.width, y: remove.minY + 0.50000 * remove.height), controlPoint1: CGPoint(x: remove.minX + 0.77614 * remove.width, y: remove.minY + 1.00000 * remove.height), controlPoint2: CGPoint(x: remove.minX + 1.00000 * remove.width, y: remove.minY + 0.77614 * remove.height))
        bezier4Path.addCurve(to: CGPoint(x: remove.minX + 0.50000 * remove.width, y: remove.minY + 0.00000 * remove.height), controlPoint1: CGPoint(x: remove.minX + 1.00000 * remove.width, y: remove.minY + 0.22386 * remove.height), controlPoint2: CGPoint(x: remove.minX + 0.77614 * remove.width, y: remove.minY + 0.00000 * remove.height))
        bezier4Path.addCurve(to: CGPoint(x: remove.minX + 0.00000 * remove.width, y: remove.minY + 0.50000 * remove.height), controlPoint1: CGPoint(x: remove.minX + 0.22386 * remove.width, y: remove.minY + 0.00000 * remove.height), controlPoint2: CGPoint(x: remove.minX + 0.00000 * remove.width, y: remove.minY + 0.22386 * remove.height))
        bezier4Path.addCurve(to: CGPoint(x: remove.minX + 0.50000 * remove.width, y: remove.minY + 1.00000 * remove.height), controlPoint1: CGPoint(x: remove.minX + 0.00000 * remove.width, y: remove.minY + 0.77614 * remove.height), controlPoint2: CGPoint(x: remove.minX + 0.22386 * remove.width, y: remove.minY + 1.00000 * remove.height))
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = bezier4Path.cgPath
        circleLayer.strokeColor = feedbackModel.stateStrokeColor.cgColor
        circleLayer.lineWidth = 1
        circleLayer.mask = clipLayer
        circleLayer.fillColor = UIColor.clear.cgColor
        
        //// Bezier 6 Drawing
        let bezier6Path = UIBezierPath()
        bezier6Path.move(to: CGPoint(x: -1 + remove.minX + 0.18000 * remove.width, y: -1 + remove.minY + 0.18000 * remove.height))
        bezier6Path.addLine(to: CGPoint(x: 1 + remove.minX + 0.82000 * remove.width, y: 1 + remove.minY + 0.82000 * remove.height))
        bezier6Path.lineCapStyle = .square
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = bezier6Path.cgPath
        lineLayer.lineWidth = 1
        lineLayer.strokeColor = feedbackModel.stateStrokeColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        
        feedbackModel.animationLayers = [circleLayer, lineLayer]
        
        /// Adding layers
        layer.addSublayer(clipLayer)
        layer.addSublayer(circleLayer)
        layer.addSublayer(lineLayer)
        
        layer.addSublayer(feedbackModel.overlayLayer)
    }
    
    // MARK: - Animation protocol
    /// Track of touch event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let cart = feedbackModel.item.recommendation?.request?.cart else {
            return
        }
        
        if let _ = touches.first, cart.isCheckoutAvaliable {
            /// Current view pressed, change state
            feedbackModel.isActive = !feedbackModel.isActive
            
            /// Call selected closure
            feedbackSelected(feedbackModel.feedbackType, containerView)
            
            for layer in feedbackModel.animationLayers {
                
                layer.lineWidth = feedbackModel.isActive ? 2 : 1
                layer.strokeColor = feedbackModel.isActive ? feedbackModel.fillColor.cgColor : UIColor.feedbackInactive.cgColor
            }
            
            /// Run animation for animation layers
            /// Only if state is active
            if feedbackModel.isActive {
                
                presentOverlay(isActive: feedbackModel.isActive, layer: feedbackModel.overlayLayer)
                
                return
            }
        }
    }
    
    override func updateState() {
        
        /// Check which one is active
        feedbackModel.isActive = feedbackModel.item.feedbackType == feedbackModel.feedbackType
        for layer in feedbackModel.animationLayers {
            
            layer.lineWidth = feedbackModel.isActive ? 2 : 1
            layer.strokeColor = feedbackModel.isActive ? feedbackModel.fillColor.cgColor : UIColor.feedbackInactive.cgColor
        }
    }
}
