//
//  TMNoConnectionView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/5/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMNoConnectionView: UIView {

    static let sharedView = TMNoConnectionView(frame: UIScreen.main.bounds)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let textLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 100.0))
            textLabel.textColor = UIColor.TMPinkColor
            textLabel.text = "No internet connection"
            textLabel.font = UIFont.MalloryBold()
            textLabel.textAlignment = .center
            textLabel.center = self.center
            
            self.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
            
            blurEffectView.addSubview(textLabel)
        }
        else {
            self.backgroundColor = UIColor.black
        }
    }
    
    func showView() {
        
        let appDelegate = TMAppDelegate.appDelegate
        appDelegate?.window?.addSubview(self)
        
        UIView.animate(withDuration: 0.3, animations: { 
            self.alpha = 1.0
        }) 
    }
    
    func dismissView() {
        
        UIView.animate(withDuration: 0.3, animations: { 
            
            self.alpha = 0.0
            
            }, completion: { finished in
                
                self.removeFromSuperview()
        }) 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
