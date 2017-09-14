//
//  TMLogoAnimationView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 6/28/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMLogoAnimationView: UIView {

    // Container view
    var containerView: UIView?
    
    // Lines Color
    var linesColor: UIColor = UIColor.black
    
    // Lines Height
    var linesHeight: CGFloat = 320.0
    
    // Lines Width
    var linesWidth: CGFloat = 10.0
    
    // Number of lines
    var numberOfLines: Int = 6
    
    // Center Point
    var centerPoint: CGPoint?
    
    // Animation Duration
    var animationDuration = 40.0
    
    // Line Layers
    var topLineLayers = [CAShapeLayer]()
    var bottomLayers = [CAShapeLayer]()
    
    // Masks
    var topShape = CAShapeLayer()
    var bottomShape = CAShapeLayer()
    
    // restart of interrupted check
    var shouldRestart = false
    
    // Angle between lines
    var lineAngle: CGFloat = 0.0
    
    // Paused
    var paused = true
    
    var shapePath: UIBezierPath {
        
        return UIBezierPath.roundedPolygonPath(self.bounds, lineWidth: 1.0, sides: 6, cornerRadius: 2.0, rotationOffset: CGFloat.pi / 6.0, scalingValue: 8)
    }
    
    // Initialization
    init(containerView: UIView, numberOfLines: Int, linesColor: UIColor, linesWidth: CGFloat, linesHeight: CGFloat) {
        
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        
        setupWithView(containerView, numberOfLines: numberOfLines, linesColor: linesColor, linesWidth: linesWidth, linesHeight: linesHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Custom Initialization
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func setupWithView(_ containerView: UIView, numberOfLines: Int, linesColor: UIColor, linesWidth: CGFloat, linesHeight: CGFloat) {
        
        self.containerView = containerView
        
        self.numberOfLines = numberOfLines
        
        self.linesColor = linesColor
        
        self.linesWidth = linesWidth
        
        self.linesHeight = linesHeight
        
        frame = containerView.bounds
        
        centerPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
        lineAngle = (2*CGFloat.pi) / CGFloat(numberOfLines)
        
        // Create Line Layers
        for _ in 0..<numberOfLines {
            
            let topLineLayer = CAShapeLayer()
            let bottomLineLayer = CAShapeLayer()
            
            topLineLayers.append(topLineLayer)
            bottomLayers.append(bottomLineLayer)
        }
        
        self.containerView?.addSubviewWithCheck(self)
    }
    
    // MARK: - Center dot drawing
    func drawCenterDot() {
        
        let dot = self.topLineLayers[0]
        
        // Make circular dot path
        dot.path = shapePath.cgPath
        
        // Center the dot in container
        dot.fillColor = UIColor.black.cgColor
        
        dot.strokeColor = UIColor.black.cgColor
        dot.lineWidth = linesWidth
        
        // Add center dot
        containerView!.layer.insertSublayer(dot, at: 1)
    }
    
    // MARK: - Progress Logic
    func showProgres(_ progress: CGFloat) {
        
        drawLines()
        shouldRestart = true
    }
    
    func drawLines() {
        
        for i in 0..<topLineLayers.count {
            
            drawLineLayerAtIndex(i)
            startAnimatingLine(self.topLineLayers[i], timeIndex: i)
            startAnimatingLine(self.bottomLayers[i], timeIndex: i)
        }
        
        bottomShape.frame = self.layer.bounds
        bottomShape.path = UIBezierPath.roundedPolygonPath(self.bounds, lineWidth: 1.0, sides: 6, cornerRadius: 0.0, rotationOffset: CGFloat.pi / 6.0, scalingValue: 5.5).cgPath
        bottomShape.lineWidth = 3.0
        bottomShape.strokeColor = UIColor.red.cgColor
        bottomShape.fillColor = UIColor.black.cgColor
        bottomShape.fillRule = kCAFillRuleEvenOdd
        layer.mask = self.bottomShape
        
        topShape.frame = self.layer.bounds
        topShape.path = UIBezierPath.roundedPolygonPath(self.bounds, lineWidth: 1.0, sides: 6, cornerRadius: 0.0, rotationOffset: CGFloat.pi / 6.0, scalingValue: 4.3).cgPath
        topShape.lineWidth = 3.0
        topShape.strokeColor = UIColor.red.cgColor
        topShape.fillColor = UIColor.black.cgColor
        topShape.fillRule = kCAFillRuleEvenOdd
        containerView!.layer.mask = self.topShape
    }
    
    func show() {
        
        showProgres(0.0)
        paused = false
    }
    
    func disco(_ on: Bool) {
        
        for i in 0..<topLineLayers.count {
            
            let topLayer = topLineLayers[i]
            let bottomLayer = bottomLayers[i]
            
            discoTimeForLine(topLayer, index: i)
            discoTimeForLine(bottomLayer, index: i)
        }
    }
    
    func discoTimeForLine(_ layer: CAShapeLayer, index: Int) {
        
        let colors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.purple]
        
        var animationsArray = [CABasicAnimation]()
        
        for i in 0..<colors.count {
            
            let colorAnimation = CABasicAnimation(keyPath: "strokeColor")
            colorAnimation.beginTime = (0.33 / Double(colors.count))  * Double(i)
            colorAnimation.duration = 0.33
            colorAnimation.fromValue = colors[i].cgColor
            colorAnimation.toValue = colors[(i + 1) % colors.count].cgColor
            
            animationsArray.append(colorAnimation)
        }
        
        let discoAnimation = CAAnimationGroup()
        discoAnimation.beginTime = 0.33 / 10.0 * Double(index)
        discoAnimation.duration = 0.33
        discoAnimation.animations = animationsArray
        discoAnimation.autoreverses = false
        discoAnimation.repeatCount = Float.infinity
        discoAnimation.isRemovedOnCompletion = true
        
        layer.add(discoAnimation, forKey: "party")
    }
    
    // MARK: - Layers drawing
    
    func drawLineLayerAtIndex(_ lineIndex: Int) {
        
        if lineIndex == 0 {
            drawCenterDot()
            return
        }
        
        let topLine = self.topLineLayers[lineIndex]
        topLine.bounds = CGRect(x: 0.0, y: 0.0, width: self.linesWidth, height: self.linesHeight)
        topLine.path = UIBezierPath(rect: topLine.bounds).cgPath
        
        topLine.position = CGPoint(x: self.centerPoint! .x, y: self.centerPoint!.y)
        topLine.fillColor = UIColor.clear.cgColor
        topLine.strokeColor = self.linesColor.cgColor
        topLine.lineWidth = self.linesWidth
        
        let bottomLine = self.bottomLayers[lineIndex]
        bottomLine.bounds = CGRect(x: 0.0, y: 0.0, width: self.linesWidth + 1.4, height: self.linesHeight)
        bottomLine.path = UIBezierPath(rect: bottomLine.bounds).cgPath
        
        bottomLine.position = CGPoint(x: self.centerPoint!.x, y: self.centerPoint!.y)
        bottomLine.fillColor = UIColor.clear.cgColor
        bottomLine.strokeColor = self.linesColor.cgColor
        bottomLine.lineWidth = self.linesWidth

        self.layer.insertSublayer(bottomLine, at: 0)
        self.containerView!.layer.insertSublayer(topLine, at: 0)
    }
    
    func startAnimatingLine(_ lineLayer: CAShapeLayer, timeIndex: Int) {
        if timeIndex != 0 {

            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.fromValue = Double(self.lineAngle) * Double(timeIndex)
            rotationAnimation.toValue = Double(CGFloat.pi * 2) + Double(self.lineAngle) * Double(timeIndex)
            rotationAnimation.duration = self.animationDuration
            rotationAnimation.fillMode = kCAFillModeForwards
            rotationAnimation.autoreverses = false
            rotationAnimation.isRemovedOnCompletion = false
            
            rotationAnimation.repeatCount = Float.infinity
            
            lineLayer.add(rotationAnimation, forKey: "rotationAnimation")
        }
    }
}
