//
//  TMBubble.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/21/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMBubble: NSObject {

    /// Generates a new path for the content view shape layer.
    ///
    /// - Parameter frame: Frame of content view.
    /// - Returns: A new instance of a path to use for the content view shape layer.
    class func generateBubble(frame: CGRect, isLeft: Bool = true, rotateDegree: CGFloat = 0) -> CGPath {
        let shapePath = UIBezierPath()
        
        shapePath.move(to: CGPoint(x: frame.minX + 0.99190 * frame.width, y: frame.minY + 0.00055 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.99912 * frame.width, y: frame.minY + 0.00582 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.99561 * frame.width, y: frame.minY + 0.00156 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.99801 * frame.width, y: frame.minY + 0.00344 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.01409 * frame.height), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.00800 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.01003 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.95826 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.99923 * frame.width, y: frame.minY + 0.96618 * frame.height), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.96232 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.96435 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.99257 * frame.width, y: frame.minY + 0.97166 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.99801 * frame.width, y: frame.minY + 0.96891 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.99561 * frame.width, y: frame.minY + 0.97079 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.98202 * frame.width, y: frame.minY + 0.97235 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.98978 * frame.width, y: frame.minY + 0.97235 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.98719 * frame.width, y: frame.minY + 0.97235 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 0.03529 * frame.width, y: frame.minY + 0.97309 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 1.0 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.96313 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.95826 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.96184 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.96031 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.01409 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.00077 * frame.width, y: frame.minY + 0.00617 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.01003 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.00800 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.00743 * frame.width, y: frame.minY + 0.00069 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00199 * frame.width, y: frame.minY + 0.00344 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00439 * frame.width, y: frame.minY + 0.00156 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.01798 * frame.width, y: frame.minY + -0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.01022 * frame.width, y: frame.minY + -0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.01281 * frame.width, y: frame.minY + -0.00000 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 0.98202 * frame.width, y: frame.minY + -0.00000 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.99212 * frame.width, y: frame.minY + 0.00060 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.98719 * frame.width, y: frame.minY + -0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.98978 * frame.width, y: frame.minY + -0.00000 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 0.99190 * frame.width, y: frame.minY + 0.00055 * frame.height))
        shapePath.close()
        
        if !isLeft {
            
            let mirrorOverXOrigin = CGAffineTransform(scaleX: 1.0, y: -1.0)
            let translate = CGAffineTransform(translationX: 0, y: frame.height)
            
            shapePath.apply(mirrorOverXOrigin)
            shapePath.apply(translate)
        }
        
        return shapePath.cgPath
    }
    
    public dynamic class func generateInfoBubble(frame: CGRect)-> CGPath {
        
        let shapePath = UIBezierPath()
        shapePath.move(to: CGPoint(x: frame.minX + 0.99190 * frame.width, y: frame.minY + 0.00053 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.99912 * frame.width, y: frame.minY + 0.00566 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.99561 * frame.width, y: frame.minY + 0.00152 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.99801 * frame.width, y: frame.minY + 0.00334 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.01371 * frame.height), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.00779 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.00976 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.98629 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.99923 * frame.width, y: frame.minY + 0.99399 * frame.height), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.99024 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.99221 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.99257 * frame.width, y: frame.minY + 0.99933 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.99801 * frame.width, y: frame.minY + 0.99666 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.99561 * frame.width, y: frame.minY + 0.99848 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.98202 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.98978 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.98719 * frame.width, y: frame.minY + 1.00000 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 10, y: frame.minY + 1.00000 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 10, y: frame.minY + 0.98629 * frame.height), controlPoint1: CGPoint(x: frame.minX + 10, y: frame.minY + 0.99221 * frame.height), controlPoint2: CGPoint(x: frame.minX + 10, y: frame.minY + 0.99024 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 10, y: frame.minY + 15), controlPoint1: CGPoint(x: frame.minX + 10, y: frame.minY + 15), controlPoint2: CGPoint(x: frame.minX + 10, y: frame.minY + 15))
        shapePath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.00000 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 0.04706 * frame.width, y: frame.minY + 0.00000 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 0.04740 * frame.width, y: frame.minY + 0.00000 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 0.98202 * frame.width, y: frame.minY + 0.00000 * frame.height))
        shapePath.addCurve(to: CGPoint(x: frame.minX + 0.99212 * frame.width, y: frame.minY + 0.00059 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.98719 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.98978 * frame.width, y: frame.minY + -0.00000 * frame.height))
        shapePath.addLine(to: CGPoint(x: frame.minX + 0.99190 * frame.width, y: frame.minY + 0.00053 * frame.height))
        shapePath.close()
        
        return shapePath.cgPath
    }
    
    /// Generates a shape layer to define the content view shape.
    ///
    /// - Returns: A new instance of a content view shape layer.
    class func generateBubble() -> CAShapeLayer {
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.cornerRadius = 2
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOpacity = 0.15
        shapeLayer.shadowOffset = CGSize(width: 0, height: 0.5)
        shapeLayer.shadowRadius = 1
        
        return shapeLayer
    }
}
