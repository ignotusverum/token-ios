//
//  TMPositiveFeedbackView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/24/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import EZSwiftExtensions

class TMPositiveFeedbackView: TMFeedbackRatingView {

    override func setupView(containerView: UIView) {
        
        super.setupView(containerView: containerView)
        
        /// Draw face
        drawFace()
    }
    
    // MARK: - Utilities
    /// Draw Face
    func drawFace(frame: CGRect = CGRect(x: 0, y: 0, width: 25, height: 25)) {
        
        //// Subframes
        let face: CGRect = CGRect(x: centerX - frame.width/2, y: frame.minY + self.frame.height/2 - frame.height/2, width: frame.width, height: frame.height)
        
        //// Face
        //// Background Drawing
        let backgroundPath = UIBezierPath()
        backgroundPath.move(to: CGPoint(x: face.minX + 0.50000 * face.width, y: face.minY + 1.00000 * face.height))
        backgroundPath.addCurve(to: CGPoint(x: face.minX + 1.00000 * face.width, y: face.minY + 0.50000 * face.height), controlPoint1: CGPoint(x: face.minX + 0.77614 * face.width, y: face.minY + 1.00000 * face.height), controlPoint2: CGPoint(x: face.minX + 1.00000 * face.width, y: face.minY + 0.77614 * face.height))
        backgroundPath.addCurve(to: CGPoint(x: face.minX + 0.50000 * face.width, y: face.minY + 0.00000 * face.height), controlPoint1: CGPoint(x: face.minX + 1.00000 * face.width, y: face.minY + 0.22386 * face.height), controlPoint2: CGPoint(x: face.minX + 0.77614 * face.width, y: face.minY + 0.00000 * face.height))
        backgroundPath.addCurve(to: CGPoint(x: face.minX + 0.00000 * face.width, y: face.minY + 0.50000 * face.height), controlPoint1: CGPoint(x: face.minX + 0.22386 * face.width, y: face.minY + 0.00000 * face.height), controlPoint2: CGPoint(x: face.minX + 0.00000 * face.width, y: face.minY + 0.22386 * face.height))
        backgroundPath.addCurve(to: CGPoint(x: face.minX + 0.50000 * face.width, y: face.minY + 1.00000 * face.height), controlPoint1: CGPoint(x: face.minX + 0.00000 * face.width, y: face.minY + 0.77614 * face.height), controlPoint2: CGPoint(x: face.minX + 0.22386 * face.width, y: face.minY + 1.00000 * face.height))
        backgroundPath.usesEvenOddFillRule = true
        
        let backgroundLayer = CAShapeLayer()
        
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.borderWidth = 1
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = feedbackModel.stateStrokeColor.cgColor
        
        /// Setting background layer
        feedbackModel.backgroundShape = backgroundLayer
        
        //// Smile Drawing
        let smilePath = UIBezierPath()
        smilePath.move(to: CGPoint(x: face.minX + 0.26876 * face.width, y: face.minY + 0.51316 * face.height))
        smilePath.addCurve(to: CGPoint(x: face.minX + 0.50000 * face.width, y: face.minY + 0.62126 * face.height), controlPoint1: CGPoint(x: face.minX + 0.26876 * face.width, y: face.minY + 0.51316 * face.height), controlPoint2: CGPoint(x: face.minX + 0.35182 * face.width, y: face.minY + 0.62126 * face.height))
        smilePath.addCurve(to: CGPoint(x: face.minX + 0.72718 * face.width, y: face.minY + 0.51316 * face.height), controlPoint1: CGPoint(x: face.minX + 0.64818 * face.width, y: face.minY + 0.62126 * face.height), controlPoint2: CGPoint(x: face.minX + 0.72718 * face.width, y: face.minY + 0.51316 * face.height))
        smilePath.lineWidth = 1
        smilePath.lineCapStyle = .square
        
        let smileLayer = CAShapeLayer()
        
        smileLayer.path = smilePath.cgPath
        smileLayer.strokeColor = feedbackModel.animationStrokeColor.cgColor
        smileLayer.fillColor = UIColor.clear.cgColor
        
        /// Adding layer to animation array
        feedbackModel.animationLayers.append(smileLayer)
        
        //// Right Brow Drawing
        let rightBrowPath = UIBezierPath()
        rightBrowPath.move(to: CGPoint(x: face.minX + 0.58912 * face.width, y: face.minY + 0.36994 * face.height))
        rightBrowPath.addCurve(to: CGPoint(x: face.minX + 0.66121 * face.width, y: face.minY + 0.34064 * face.height), controlPoint1: CGPoint(x: face.minX + 0.58912 * face.width, y: face.minY + 0.36994 * face.height), controlPoint2: CGPoint(x: face.minX + 0.61000 * face.width, y: face.minY + 0.34064 * face.height))
        rightBrowPath.addCurve(to: CGPoint(x: face.minX + 0.73329 * face.width, y: face.minY + 0.36994 * face.height), controlPoint1: CGPoint(x: face.minX + 0.71242 * face.width, y: face.minY + 0.34064 * face.height), controlPoint2: CGPoint(x: face.minX + 0.73329 * face.width, y: face.minY + 0.36994 * face.height))
        rightBrowPath.lineWidth = 0.2
        rightBrowPath.lineCapStyle = .square
        
        let rightBrowLayer = CAShapeLayer()
        
        rightBrowLayer.path = rightBrowPath.cgPath
        rightBrowLayer.fillColor = UIColor.clear.cgColor
        rightBrowLayer.strokeColor = feedbackModel.animationStrokeColor.cgColor
        
        /// Adding layer to animation array
        feedbackModel.animationLayers.append(rightBrowLayer)
        
        //// Left Brow Drawing
        let leftBrowPath = UIBezierPath()
        leftBrowPath.move(to: CGPoint(x: face.minX + 0.26800 * face.width, y: face.minY + 0.37000 * face.height))
        leftBrowPath.addCurve(to: CGPoint(x: face.minX + 0.34008 * face.width, y: face.minY + 0.34070 * face.height), controlPoint1: CGPoint(x: face.minX + 0.26800 * face.width, y: face.minY + 0.37000 * face.height), controlPoint2: CGPoint(x: face.minX + 0.28888 * face.width, y: face.minY + 0.34070 * face.height))
        leftBrowPath.addCurve(to: CGPoint(x: face.minX + 0.41217 * face.width, y: face.minY + 0.37000 * face.height), controlPoint1: CGPoint(x: face.minX + 0.39129 * face.width, y: face.minY + 0.34070 * face.height), controlPoint2: CGPoint(x: face.minX + 0.41217 * face.width, y: face.minY + 0.37000 * face.height))
        leftBrowPath.lineWidth = 0.2
        leftBrowPath.lineCapStyle = .square
        
        let leftBrowLayer = CAShapeLayer()
        
        leftBrowLayer.path = leftBrowPath.cgPath
        leftBrowLayer.fillColor = UIColor.clear.cgColor
        leftBrowLayer.strokeColor = feedbackModel.animationStrokeColor.cgColor
        
        /// Adding layer to animation array
        feedbackModel.animationLayers.append(leftBrowLayer)
        
        layer.anchorPoint = center
        
        /// Adding layers
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(smileLayer)
        layer.insertSublayer(leftBrowLayer, above: smileLayer)
        layer.insertSublayer(rightBrowLayer, above: smileLayer)
        
        layer.addSublayer(feedbackModel.overlayLayer)
    }
    
    // MARK: - Animation protocol
    override func runFeedbackAnimationFor(isAnimated: Bool, layer: CAShapeLayer) {

        /// Change animation layers colors
        layer.strokeColor = feedbackModel.animationStrokeColor.cgColor

        if isAnimated {
            let upAnimation = CAKeyframeAnimation(keyPath: "position.y")
            upAnimation.values = [layer.position.y, layer.position.y + 1, layer.position.y, layer.position.y - 1]
            upAnimation.duration = 0.4
            upAnimation.timingFunction = feedbackModel.timingFunction
            upAnimation.fillMode = kCAFillModeForwards
            upAnimation.autoreverses = true
            
            upAnimation.isRemovedOnCompletion = false
            upAnimation.repeatCount = 2
            
            layer.add(upAnimation, forKey: "positiveAnimation")
        }
    }
}
