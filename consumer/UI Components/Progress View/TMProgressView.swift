//
//  TMProgressControl.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/9/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMProgressView: UIView {
    
    /// Progress view model
    var progressModel: TMProgressViewModel?
    
    /// Description layers
    private var desciprionLayers: [CALayer] = []
    
    /// Circle layers
    private var circleLayers: [CALayer] = []
    
    ///  View Constants
    // Descripion - Circle offset
    var contentOffset: CGFloat = 25.0
    
    /// Inset
    var contentInsetPoint: CGPoint = CGPoint.zero
    var insetBetweenContent: CGFloat = DeviceType.IS_IPHONE_5 ? -15 : -20
    
    // Progress line width
    private let lineWidth: CGFloat = 1.0
    
    // Pin circle radius
    private let circleRadius: CGFloat = DeviceType.IS_IPHONE_5 ? 3.0 : 4.5
    
    /// Initializers
    func setup(progressModel: TMProgressViewModel?) {
        
        /// Setting background color
        backgroundColor = UIColor.clear
        
        self.progressModel = progressModel

        /// Drawing logic
        customInit()
    }
    
    func customInit() {
        
        // Safety check
        guard let progressModel = progressModel else {
            return
        }
        
        /// Last point that we drawed
        var lastPoint = CGPoint(x: 0.0, y: 0.0 + circleRadius)
        /// First point that we drawed
        var fromPoint = CGPoint(x: 0.0, y: 0.0 + circleRadius)
        
        var previousHeight: CGFloat = 0.0
        
        // Building circles for statuses
        for (index, status) in progressModel.statuses.enumerated() {
            
            let circle = configureCircle(UIBezierPath(), centerY: previousHeight)
            let circleLayer = layerWithCircle(circle, status: status)
            
            circleLayer.bounds = circleLayer.frame.offsetBy(dx: contentInsetPoint.x, dy: contentInsetPoint.y)
            
            /// Adding gradient fill color
            if status.status == .pending && status.active {
                
                let gradient = gradientCircleLayer(frame: circleLayer.bounds, shape: circleLayer)
                gradient.bounds = circleLayer.frame.offsetBy(dx: contentInsetPoint.x, dy: contentInsetPoint.y)
                
                layer.addSublayer(gradient)
            }
                /// Default filling color
            else {
            
                layer.addSublayer(circleLayer)
            }
            
            createTitle(status, yPos: previousHeight)
            
            /// Drawing line
            if index < progressModel.statuses.count {
                
                fromPoint = lastPoint
                let toPoint = CGPoint(x: 0.0, y: index == 0 ? circleRadius : previousHeight - circleRadius)
                lastPoint = CGPoint(x: 0.0, y: previousHeight + circleRadius)
                
                let line = lineWith(start: fromPoint, end: toPoint)
                let lineLayer = layerWithLine(line, strokeColor: UIColor.TMContactsTextColor)
                
                lineLayer.bounds = lineLayer.frame.offsetBy(dx: contentInsetPoint.x, dy: contentInsetPoint.y)
                
                layer.addSublayer(lineLayer)
            }
            
            let titleHeight = status.title.heightWithConstrainedWidth(frame.width - 20)
            let descriptionHeight = status.description.heightWithConstrainedWidth(frame.width - 40) - 10
            
            let spacing: CGFloat = DeviceType.IS_IPHONE_6P ? 34.0 : 24.0
            previousHeight += titleHeight + 3.0 + (status.active ? descriptionHeight : 0) + spacing
        }
    }
    
    /// Adjusts circle bezier path to centerY
    private func configureCircle(_ bezierPath: UIBezierPath, centerY: CGFloat)-> UIBezierPath {
        
        bezierPath.addArc(withCenter: CGPoint(x: 0.0, y: centerY), radius: circleRadius, startAngle: CGFloat.pi/2, endAngle: -CGFloat.pi/2, clockwise: true)
        bezierPath.addArc(withCenter: CGPoint(x: 0.0, y: centerY), radius: circleRadius, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi/2, clockwise: true)
        
        return bezierPath
    }
    
    /// Configure Description Label
    private func createTitle(_ status: TMStatusData, yPos: CGFloat) {
        
        let dateLabel = UILabel()
        
        let label = UILabel()
        let spacing = DeviceType.IS_IPHONE_5 ? 2 * circleRadius : circleRadius
        label.setFrameY(yPos + spacing )
        label.setFrameX(-insetBetweenContent-contentInsetPoint.x)
        label.setFrameWidth(frame.width - 20)
        
        label.numberOfLines = 0
        
        /// Combined details - title + date + description
        let combinedDetails = NSMutableAttributedString(string: "")
        
        combinedDetails.append(status.title)
        
        label.attributedText = combinedDetails
        
        /// Gradient
        if status.status == .pending, status.active {
            
            let gradientImage = UIImage(named: "gradient-status")!
            label.textColor = UIColor.init(patternImage: gradientImage)
        }
        
        label.sizeToFit()
        
        addSubview(label)
        
        /// Show date + description only if it's current status
        if status.active {
            
            /// Create date label
            dateLabel.setFrameY(label.frameY())
            dateLabel.setFrameX(label.frameX() + label.frameWidth() + 10)
            dateLabel.setFrameWidth(frame.width - 20)
            
            dateLabel.numberOfLines = 0
            
            dateLabel.attributedText = status.dateString
            
            dateLabel.sizeToFit()
            
            /// Create description label
            createDescription(status, previousY: label.frameY())
        }
        
        addSubview(dateLabel)
    }
    
    private func createDescription(_ status: TMStatusData, previousY: CGFloat) {
        
        let label = UILabel()
        label.setFrameY(previousY + 5.0)
        label.setFrameX(-insetBetweenContent-contentInsetPoint.x)
        label.setFrameWidth(frame.width - 70)
        
        label.numberOfLines = 0
        
        label.attributedText = status.description
        label.sizeToFit()
        
        addSubview(label)
    }
    
    /// Create circle layer
    private func layerWithCircle(_ bezierPath: UIBezierPath, status: TMStatusData)-> CAShapeLayer {
        
        let circleLayer = CAShapeLayer()
        circleLayer.frame = bounds
        
        // Circle fill color
        let fillColor = status.active ? status.color : UIColor.white
        
        // Circle stroke color
        let strokeColor = status.active ? status.color : UIColor.TMContactsTextColor
        
        circleLayer.path = bezierPath.cgPath
        circleLayer.strokeColor = strokeColor.cgColor
        circleLayer.fillColor = fillColor.cgColor
        circleLayer.lineWidth = lineWidth
        circleLayer.lineJoin = kCALineJoinBevel
        
        return circleLayer
    }
    
    /// Gradient layer
    private func gradientCircleLayer(frame: CGRect, shape: CAShapeLayer)-> CAGradientLayer {
        
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.firstGradientColor.cgColor,
                           UIColor.secondGradientColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.mask = shape
        
        return gradient
    }
    
    /// Create line bezier path with points
    private func lineWith(start: CGPoint, end: CGPoint)-> UIBezierPath {
        
        let line = UIBezierPath()
        line.move(to: start)
        line.addLine(to: end)
        
        return line
    }
    
    /// Line with bezier path and stroke color
    private func layerWithLine(_ bezierPath: UIBezierPath, strokeColor: UIColor)-> CAShapeLayer {
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = bezierPath.cgPath
        lineLayer.strokeColor = strokeColor.cgColor
        lineLayer.fillColor = nil
        lineLayer.lineWidth = lineWidth
        
        lineLayer.lineJoin = kCALineJoinRound
        lineLayer.lineDashPattern = [NSNumber(value: 1), NSNumber(value: 2)]
        
        return lineLayer
    }
}
