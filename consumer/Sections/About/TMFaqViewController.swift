//
//  TMAboutViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 7/6/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import EZSwiftExtensions

enum AboutControllerRows: Int {
    
    case versionCell = 0
}

class TMFAQViewController: UIViewController {

    // Text View - Terms copy
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTitleText("FAQ", color: UIColor.white)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TMAnalytics.trackScreenWithID(.s24)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let copy = TMCopy.sharedCopy.faqHTMLCode {
            
            let copyString = NSMutableAttributedString(attributedString: copy)
            
            self.textView.attributedText = copyString.color(UIColor.white)
            
            self.textView.textContainerInset = UIEdgeInsets(top: 20.0, left: 30.0, bottom: 0.0, right: 30.0)
        }
    }
}
