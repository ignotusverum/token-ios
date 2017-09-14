//
//  TMActivityIndicatorView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/17/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

var TMActivityIndicatorViewDefaultDelay = 1.5
var kPerformActionDelay = 1.25
var kFadeAnimationTime = 0.32

var kDefaultDoneText = "Done"
var kDefaultLoadingText = "Loading..."

import EZSwiftExtensions

class TMActivityIndicatorView: UIView {
    
    fileprivate var viewContainer: UIView?
    fileprivate var statusLabel: UILabel?
    
    static let sharedView = TMActivityIndicatorView(frame: UIScreen.main.bounds)
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.viewContainer = UIView(frame: self.bounds)
        self.viewContainer!.alpha = 0.0
        self.viewContainer!.backgroundColor = UIColor.clear
        self.addSubview(viewContainer!)
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = self.bounds
        self.viewContainer?.addSubview(visualEffectView)
        
        self.statusLabel = UILabel(frame: CGRect(x: 25.0, y: (self.frame.size.height/3.0) + 50.0, width: self.frame.size.width - 50.0, height: 30.0))
        self.statusLabel!.backgroundColor = .clear
        self.statusLabel!.font = UIFont(name: TMFontName, size: 16.0)
        self.statusLabel!.textAlignment = .center
        
        self.viewContainer?.addSubview(self.statusLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Show Class Methods
    
    class func showWithMessage(_ loadMessage: String, doneMessage: String, dismissDelay: CGFloat) {
        
        self.sharedView.showIndicatorWithMessage(loadMessage, doneMessage: doneMessage, dismissDelay: dismissDelay)
    }
    
    class func showMessage(_ loadMessage: String) {
        
        self.sharedView.showIndicatorWithMessage(loadMessage, doneMessage: nil, dismissDelay: 0.0)
    }
    
    class func show() {
        
        self.showMessage(kDefaultLoadingText)
    }
    
    // MARK: - Animation
    
    func showIndicatorWithMessage(_ loadMessage: String, doneMessage: String?, dismissDelay: CGFloat) {
        
        UIApplication.shared.delegate?.window!?.addSubview(self)
        
        self.statusLabel?.text = loadMessage
        
        UIView.animate(withDuration: kFadeAnimationTime) { () -> Void in
            
            self.viewContainer?.alpha = 1.0
        }
        
        if dismissDelay > 0 {
            ez.runThisAfterDelay(seconds: Double(dismissDelay), after: { () -> () in
                self.dismissIndicatorWithMessage(doneMessage, completed: nil)
            })
        }
    }
    
    func dismissIndicatorWithMessage(_ message: String?, completed: (()-> Void)?) {
        
        self.statusLabel!.text = (message != nil) ? message : kDefaultDoneText
        
        UIView.animate(withDuration: kFadeAnimationTime, delay: TMActivityIndicatorViewDefaultDelay, options: .layoutSubviews, animations: { () -> Void in
            
            self.viewContainer?.alpha = 0.0
            
        }) { finished -> Void in
            
            self.removeFromSuperview()
            if completed != nil {
                completed!()
            }
        }
        
    }
}
