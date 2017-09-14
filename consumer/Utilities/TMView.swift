//
//  TMView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/2/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

extension UIView {

    //MARK: - Getters
    func frameX() -> CGFloat {
        return frame.origin.x
    }
    
    func frameY() -> CGFloat {
        return frame.origin.y
    }
    
    func frameWidth() -> CGFloat {
        return frame.size.width
    }
    
    func frameHeight() -> CGFloat {
        return frame.size.height
    }
    
    //MARK: - Setters
    func setFrameX(_ x: CGFloat) {
        frame = CGRect(x: x, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
    }
    
    func setFrameY(_ y: CGFloat) {
        frame = CGRect(x: frame.origin.x, y: y, width: frame.size.width, height: frame.size.height)
    }
    
    func setFrameWidth(_ width: CGFloat) {
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: width, height: frame.size.height)
    }
    
    func setFrameHeight(_ height: CGFloat) {
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: height)
    }
    
    func addSubviewWithCheck(_ subview: UIView) {
     
        if !self.subviews.contains(subview) {
            self.addSubview(subview)
        }
    }
    
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        
        return UINib( nibName: nibNamed, bundle: bundle ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
    
    var screenshot: UIImage {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        
        if let tableVew = self as? UITableView {
            
            tableVew.superview?.layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        else {
            
            layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func layerGradientWithColor(_ color: UIColor, secondColor: UIColor) {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame = self.bounds
        
        layer.colors = [color.cgColor, secondColor.cgColor]
        
        self.layer.insertSublayer(layer, at: 0)
    }
    
    // Gradient
    func addGradient(_ index: UInt32 = 1) {
        
        let gradientMask = CAGradientLayer()
        gradientMask.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
        gradientMask.colors = [UIColor.firstGradientColor.cgColor, UIColor.secondGradientColor.cgColor]
        gradientMask.startPoint = CGPoint(x: 0.0, y: 0.7)
        gradientMask.endPoint = CGPoint(x: 0.7, y: 0.3)
        
        self.layer.insertSublayer(gradientMask, at: index)
    }
    
    func addGradienBorder(_ cornerRadius: CGFloat = 0.0, lineWidth: CGFloat = 2.0)-> CAGradientLayer {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =  CGRect(origin: CGPoint.zero, size: self.bounds.size)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.7)
        gradientLayer.endPoint = CGPoint(x: 0.7, y: 0.3)
        gradientLayer.colors = [UIColor.firstGradientColor.cgColor, UIColor.secondGradientColor.cgColor]
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.lineWidth = lineWidth
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        self.layer.addSublayer(gradientLayer)
        
        return gradientLayer
    }
    
    func addInnerGradientBorder(_ cornerRadius: CGFloat = 0.0, lineWidth: CGFloat = 2.0)-> CAGradientLayer {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =  CGRect(origin: CGPoint.zero, size: self.bounds.size)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.7)
        gradientLayer.endPoint = CGPoint(x: 0.7, y: 0.3)
        gradientLayer.colors = [UIColor.firstGradientColor.cgColor, UIColor.secondGradientColor.cgColor]
        
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.lineWidth = lineWidth
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(x: bounds.x + lineWidth/2, y: bounds.y + lineWidth/2, w: bounds.size.width - lineWidth, h: bounds.size.height - lineWidth), cornerRadius: cornerRadius).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        layer.addSublayer(gradientLayer)
        
        return gradientLayer
    }
    
    // Shadow
    func addShadow(cornerRadius: CGFloat = 0.0) {
        
        self.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.1
        self.clipsToBounds = false
        
        let shadowFrame: CGRect = self.layer.bounds
        let shadowPath: CGPath = UIBezierPath(roundedRect: shadowFrame, cornerRadius: cornerRadius).cgPath
        self.layer.shadowPath = shadowPath
    }
}
