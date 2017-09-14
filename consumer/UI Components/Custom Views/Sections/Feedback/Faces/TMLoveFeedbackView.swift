//
//  TMLoveFeedbackView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/29/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class TMLoveFeedbackView: TMFeedbackRatingView {
    
    override func setupView(containerView: UIView) {
        
        /// Adding view as subview
        super.setupView(containerView: containerView)
        
        /// Draw face
        drawFace()
    }
    
    // MARK: - Utilities
    /// Draw Face
    func drawFace(frame: CGRect = CGRect(x: 0, y: 0, width: 30, height: 25)) {
        
        //// Subframes
        let group: CGRect = CGRect(x: centerX - frame.width/2, y: frame.minY + self.frame.height/2 - frame.height/2, width: frame.width, height: frame.height)
        
        //// Face
        //// Background Drawing
        let backgroundPath = UIBezierPath()
        backgroundPath.move(to: CGPoint(x: group.minX + 0.07239 * group.width, y: group.minY + 0.08527 * group.height))
        backgroundPath.addCurve(to: CGPoint(x: group.minX + 0.07239 * group.width, y: group.minY + 0.49570 * group.height), controlPoint1: CGPoint(x: group.minX + -0.02418 * group.width, y: group.minY + 0.19896 * group.height), controlPoint2: CGPoint(x: group.minX + -0.02408 * group.width, y: group.minY + 0.38190 * group.height))
        backgroundPath.addLine(to: CGPoint(x: group.minX + 0.49973 * group.width, y: group.minY + 1.00000 * group.height))
        backgroundPath.addCurve(to: CGPoint(x: group.minX + 0.92758 * group.width, y: group.minY + 0.49628 * group.height), controlPoint1: CGPoint(x: group.minX + 0.64235 * group.width, y: group.minY + 0.83210 * group.height), controlPoint2: CGPoint(x: group.minX + 0.78496 * group.width, y: group.minY + 0.66419 * group.height))
        backgroundPath.addCurve(to: CGPoint(x: group.minX + 0.92758 * group.width, y: group.minY + 0.08585 * group.height), controlPoint1: CGPoint(x: group.minX + 1.02414 * group.width, y: group.minY + 0.38259 * group.height), controlPoint2: CGPoint(x: group.minX + 1.02414 * group.width, y: group.minY + 0.19954 * group.height))
        backgroundPath.addCurve(to: CGPoint(x: group.minX + 0.57896 * group.width, y: group.minY + 0.08585 * group.height), controlPoint1: CGPoint(x: group.minX + 0.83101 * group.width, y: group.minY + -0.02784 * group.height), controlPoint2: CGPoint(x: group.minX + 0.67553 * group.width, y: group.minY + -0.02784 * group.height))
        backgroundPath.addLine(to: CGPoint(x: group.minX + 0.50023 * group.width, y: group.minY + 0.17855 * group.height))
        backgroundPath.addLine(to: CGPoint(x: group.minX + 0.42100 * group.width, y: group.minY + 0.08527 * group.height))
        backgroundPath.addCurve(to: CGPoint(x: group.minX + 0.07239 * group.width, y: group.minY + 0.08527 * group.height), controlPoint1: CGPoint(x: group.minX + 0.32443 * group.width, y: group.minY + -0.02842 * group.height), controlPoint2: CGPoint(x: group.minX + 0.16895 * group.width, y: group.minY + -0.02842 * group.height))
        backgroundPath.addLine(to: CGPoint(x: group.minX + 0.07239 * group.width, y: group.minY + 0.08527 * group.height))
        
        let backgroundLayer = CAShapeLayer()
        
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.borderWidth = 1
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = feedbackModel.stateStrokeColor.cgColor
        
        /// Setting background layer
        feedbackModel.backgroundShape = backgroundLayer
        
        /// Adding layers
        layer.addSublayer(backgroundLayer)
        
        layer.anchorPoint = center
        
        /// Adding layers to animation
        feedbackModel.animationLayers.append(backgroundLayer)
        
        layer.addSublayer(feedbackModel.overlayLayer)
    }
    
    // MARK: - Animation protocol
    override func runFeedbackAnimationFor(isAnimated: Bool, layer: CAShapeLayer) {
        
        if isAnimated {
            let scaleAnimation = CABasicAnimation(keyPath: "transform")
            var transform = CATransform3DIdentity
            transform = CATransform3DTranslate(transform, self.bounds.size.width/2, self.bounds.size.height/2, 0)
            transform = CATransform3DScale(transform, 1.2, 1.2, 1)
            transform = CATransform3DTranslate(transform, -self.bounds.size.width/2, -self.bounds.size.height/2, 0)
            scaleAnimation.toValue = transform
            scaleAnimation.timingFunction = feedbackModel.timingFunction
            scaleAnimation.fillMode = kCAFillModeForwards
            scaleAnimation.autoreverses = true
            
            scaleAnimation.isRemovedOnCompletion = false
            scaleAnimation.repeatCount = 1
            
            layer.add(scaleAnimation, forKey: "scaleAnimation")
        }
    }
}

