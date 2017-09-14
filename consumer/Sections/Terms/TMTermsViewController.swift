//
//  TMTermsViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import  EZSwiftExtensions

class TMTermsViewController: UIViewController {
    
    // Text View - Terms copy
    @IBOutlet var textView: UITextView!
    
    // Back button
    @IBOutlet var backButton: UIBarButtonItem!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if presentedFromMenu {
            return .lightContent
        } else {
            return .default
        }
    }
    
    var presentedFromMenu = true
    
    // MARK: - Controller lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let copy = TMCopy.sharedCopy.privaryHTMLCode {
            
            let copyString = NSMutableAttributedString(attributedString: copy)
            
            textView.attributedText = copyString.color(UIColor.white)
            
            textView.textContainerInset = UIEdgeInsets(top: 20.0, left: 30.0, bottom: 0.0, right: 30.0)
            
            if presentedFromMenu {
                textView.textColor = UIColor.white
                
                let backImage = UIImage(named: "backButton")
                backButton.image = backImage
                addTitleText("TERMS & PRIVACY", color: UIColor.white)
            } else {
                textView.textColor = UIColor.black
                
                let crossImage = UIImage(named: "closeButton")
                backButton.image = crossImage
                backButton.tintColor = UIColor.black
                
                let whiteColor = UIColor.TMColorWithRGBFloat(249, green: 249, blue: 249, alpha: 1)
                view.backgroundColor = whiteColor
                
                navigationBarColor = whiteColor
                textView.backgroundColor = whiteColor
                addTitleText("TERMS & PRIVACY", color: UIColor.black)
            }
        }
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        TMAnalytics.trackScreenWithID(.s23)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
}
