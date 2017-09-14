//
//  ENMBadgedBarButtonItem.swift
//  TestBadge-Swift
//
//  Created by Eric Miller on 6/2/14.
//  Copyright (c) 2014 Xero. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

let kENMDefaultPadding: CGFloat = 5.0
let kENMDefaultMinSize: CGFloat = 8.0
let kENMDefaultOriginX: CGFloat = 30.0
let kENMDefaultOriginY: CGFloat = 14.0

class ENMBadgedBarButtonItem: UIBarButtonItem {
    
    // Adding request for kvo
    var request: TMRequest? {
        didSet {
            
            request?.addObserver(self, forKeyPath: TMRequestRelationships.activities.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
            
            let badgeNumber = request?.conversationNotificationCount
            
            if let badgeCount = badgeNumber {
             
                self.badgeValue = "\(badgeCount)"
            }
        }
    }
    
    var badgeLabel: UILabel = UILabel()
    var badgeValue: String = "" {
        didSet {
            guard !shouldBadgeHide(badgeValue as NSString) else {
                removeBadge()
                return
            }
            
            if (badgeLabel.superview != nil) {
                updateBadgeValueAnimated(true)
            } else {
                badgeLabel = self.createBadgeLabel()
                updateBadgeProperties()
                customView!.addSubview(badgeLabel)
                
                // Pull the setting of the value and layer border radius off onto the next event loop.
                DispatchQueue.main.async(execute: { () -> Void in
                    self.badgeLabel.text = self.badgeValue
                    self.updateBadgeFrame()
                })
            }
        }
    }
    var badgeBackgroundColor: UIColor = UIColor.TMColorWithRGBFloat(255.0, green: 103.0, blue: 93.0, alpha: 1.0) {
        didSet {
            refreshBadgeLabelProperties()
        }
    }
    var badgeTextColor: UIColor = UIColor.white {
        didSet {
            refreshBadgeLabelProperties()
        }
    }
    var badgeFont: UIFont = UIFont.MalloryMedium(8.0) {
        didSet {
            refreshBadgeLabelProperties()
        }
    }
    var badgePadding: CGFloat {
        get {
            return kENMDefaultPadding
        }
    }
    var badgeMinSize: CGFloat {
        get {
            return kENMDefaultMinSize
        }
    }
    var badgeOriginX: CGFloat = kENMDefaultOriginX
    var badgeOriginY: CGFloat {
        get {
            return kENMDefaultOriginY
        }
    }
    var shouldHideBadgeAtZero: Bool = true
    var shouldAnimateBadge: Bool = true
    
    init(customView: UIView, value: String, request: TMRequest) {
        
        badgeValue = value
        badgeOriginX = customView.frame.size.width - badgeLabel.frame.size.width / 2
        
        super.init()
        self.customView = customView
        
        defer {
        
            self.request = request
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let newValue = change?[NSKeyValueChangeKey.newKey] {
            print("Name changed: \(newValue)")
            
            if let newValue = newValue as? NSNumber {
                
                self.badgeValue = newValue.stringValue
                badgeOriginX = customView!.frame.size.width - badgeLabel.frame.size.width / 2
                self.updateBadgeValueAnimated(true)
                
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        self.request?.removeObserver(self, forKeyPath: TMRequestRelationships.activities.rawValue)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Utilities
extension ENMBadgedBarButtonItem {
    
    func refreshBadgeLabelProperties() {
        badgeLabel.textColor = badgeTextColor;
        badgeLabel.backgroundColor = badgeBackgroundColor;
        badgeLabel.font = badgeFont;
    }
    
    func updateBadgeValueAnimated(_ animated: Bool) {
        
        if (animated && shouldAnimateBadge && (badgeLabel.text != badgeValue)) {
            let animation: CABasicAnimation = CABasicAnimation()
            animation.keyPath = "transform.scale"
            animation.fromValue = 1.5
            animation.toValue = 1
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 1.3, 1.0, 1.0)
            badgeLabel.layer.add(animation, forKey: "bounceAnimation")
        }
        
        badgeLabel.text = self.badgeValue;
        
        let duration: Double = animated ? 0.2 : 0.0
        UIView.animate(withDuration: duration, animations: {
            self.updateBadgeFrame()
        }) 
    }
    
    func updateBadgeFrame() {
        let expectedLabelSize: CGSize = badgeExpectedSize()
        var minHeight = expectedLabelSize.height
        
        minHeight = (minHeight < badgeMinSize) ? badgeMinSize : expectedLabelSize.height
        var minWidth = expectedLabelSize.width
        let padding = badgePadding
        
        minWidth = (minWidth < minHeight) ? minHeight : expectedLabelSize.width
        
        self.badgeLabel.frame = CGRect(
            x: self.badgeOriginX,
            y: self.badgeOriginY,
            width: minWidth + padding,
            height: minHeight + padding
        )
        self.badgeLabel.layer.cornerRadius = (minHeight + padding) / 2
    }
    
    func removeBadge() {
        UIView.animate(withDuration: 0.2,
            animations: {
                self.badgeLabel.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            }, completion: { finished in
                self.badgeLabel.removeFromSuperview()
        })
    }
}

// MARK: - Internal Helpers
extension ENMBadgedBarButtonItem {
    
    func createBadgeLabel() -> UILabel {
        let frame = CGRect(x: badgeOriginX, y: badgeOriginY, width: 15, height: 15)
        let label = UILabel(frame: frame)
        label.textColor = badgeTextColor
        label.font = badgeFont
        label.backgroundColor = badgeBackgroundColor
        label.textAlignment = NSTextAlignment.center
        label.layer.cornerRadius = frame.size.width / 2
        label.clipsToBounds = true
        
        return label
    }
    
    func badgeExpectedSize() -> CGSize {
        let frameLabel: UILabel = self.duplicateLabel(badgeLabel)
        frameLabel.sizeToFit()
        let expectedLabelSize: CGSize = frameLabel.frame.size;
        
        return expectedLabelSize
    }
    
    func duplicateLabel(_ labelToCopy: UILabel) -> UILabel {
        let dupLabel = UILabel(frame: labelToCopy.frame)
        dupLabel.text = labelToCopy.text
        dupLabel.font = labelToCopy.font
        
        return dupLabel
    }
    
    func shouldBadgeHide(_ value: NSString) -> Bool {
        let b2 = value.isEqual(to: "")
        let b3 = value.isEqual(to: "0")
        let b4 = shouldHideBadgeAtZero
        if ((b2 || b3) && b4) {
            return true
        }
        return false
    }
    
    func updateBadgeProperties() {
        badgeOriginX = self.customView!.frame.size.width - badgeLabel.frame.size.width/2
    }
}
