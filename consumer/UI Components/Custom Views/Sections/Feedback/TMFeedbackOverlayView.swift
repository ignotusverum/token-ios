//
//  TMFeedbackOverlayView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/28/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMFeedbackOverlayView: UIView {
    
    class func drawOverlayView(frame: CGRect = CGRect(x: 0, y: 0, width: 83, height: 56), color: UIColor, copy: String, textColor: UIColor = UIColor.white)-> CAShapeLayer {
        
        // This non-generic function dramatically improves compilation times of complex expressions.
        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }
        
        //// Subframes
        let group: CGRect = CGRect(x: frame.minX + 2, y: frame.minY, width: frame.width - 3, height: frame.height - 3.51)
        
        //// Group
        //// Bubble Drawing
        let bubblePath = UIBezierPath()
        bubblePath.move(to: CGPoint(x: group.minX + 0.99782 * group.width, y: group.minY + 0.03813 * group.height))
        bubblePath.addCurve(to: CGPoint(x: group.minX + 0.97254 * group.width, y: group.minY + 0.00000 * group.height), controlPoint1: CGPoint(x: group.minX + 0.99775 * group.width, y: group.minY + 0.01705 * group.height), controlPoint2: CGPoint(x: group.minX + 0.98650 * group.width, y: group.minY + -0.00002 * group.height))
        bubblePath.addLine(to: CGPoint(x: group.minX + 0.02510 * group.width, y: group.minY + 0.00139 * group.height))
        bubblePath.addCurve(to: CGPoint(x: group.minX + 0.00000 * group.width, y: group.minY + 0.03938 * group.height), controlPoint1: CGPoint(x: group.minX + 0.01121 * group.width, y: group.minY + 0.00141 * group.height), controlPoint2: CGPoint(x: group.minX + -0.00003 * group.width, y: group.minY + 0.01833 * group.height))
        bubblePath.addLine(to: CGPoint(x: group.minX + 0.00116 * group.width, y: group.minY + 0.77282 * group.height))
        bubblePath.addCurve(to: CGPoint(x: group.minX + 0.02641 * group.width, y: group.minY + 0.81070 * group.height), controlPoint1: CGPoint(x: group.minX + 0.00120 * group.width, y: group.minY + 0.79378 * group.height), controlPoint2: CGPoint(x: group.minX + 0.01238 * group.width, y: group.minY + 0.81074 * group.height))
        bubblePath.addLine(to: CGPoint(x: group.minX + 0.37400 * group.width, y: group.minY + 0.80963 * group.height))
        bubblePath.addLine(to: CGPoint(x: group.minX + 0.49999 * group.width, y: group.minY + 1.00000 * group.height))
        bubblePath.addLine(to: CGPoint(x: group.minX + 0.62598 * group.width, y: group.minY + 0.80937 * group.height))
        bubblePath.addLine(to: CGPoint(x: group.minX + 0.97498 * group.width, y: group.minY + 0.80829 * group.height))
        bubblePath.addCurve(to: CGPoint(x: group.minX + 1.00000 * group.width, y: group.minY + 0.77004 * group.height), controlPoint1: CGPoint(x: group.minX + 0.98886 * group.width, y: group.minY + 0.80824 * group.height), controlPoint2: CGPoint(x: group.minX + 1.00006 * group.width, y: group.minY + 0.79133 * group.height))
        bubblePath.addLine(to: CGPoint(x: group.minX + 0.99782 * group.width, y: group.minY + 0.03813 * group.height))
        
        bubblePath.usesEvenOddFillRule = true
        
        let bubbleLayer = CAShapeLayer()
        
        bubbleLayer.path = bubblePath.cgPath
        bubbleLayer.shadowPath = bubblePath.cgPath
        
        bubbleLayer.fillColor = color.cgColor
        bubbleLayer.shadowOffset = CGSize(width: 0, height: 1.0)
        bubbleLayer.shadowColor = UIColor.black.cgColor
        bubbleLayer.shadowRadius = 1
        bubbleLayer.shadowOpacity = 0.2
        bubbleLayer.opacity = 0
        
        //// Label Drawing
        
        let fontSize: CGFloat = DeviceType.IS_IPHONE_5 ? 9 : 11
        
        let textLayer = CATextLayer()
        textLayer.string = copy
        textLayer.fontSize = fontSize
        textLayer.font = UIFont.MalloryBold(fontSize)
      
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = kCAAlignmentCenter
        
        let textFrame = CGRect(x: group.x, y: group.y + group.height/2 - 10, w: group.width, h: group.height)
        textLayer.frame = textFrame

        textLayer.foregroundColor = textColor.cgColor
        
        bubbleLayer.addSublayer(textLayer)
        
        return bubbleLayer
    }
}
