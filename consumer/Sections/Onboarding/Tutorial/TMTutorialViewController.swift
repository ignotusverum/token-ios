//
//  TMTutorialViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 9/9/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMTutorialViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel! {
        didSet {
         
            self.titleLabel.attributedText = NSMutableAttributedString.initWithString(titleString, lineSpacing: 5.0, aligntment: .center)
        }
    }
    
    @IBOutlet var imageView: UIImageView! {
        didSet {
            
            self.imageView.image = UIImage(named: self.imageName)
        }
    }
    
    fileprivate var imageName = ""
    fileprivate var titleString = ""
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //Layout is done here instead of with autolayout because this view is instantiated when the user scrolls to it in a scroll view, since auto layout takes some time to layout its constraints, it can cause some lag while scrolling.
        
        imageView.frame = view.bounds
        let titleLabelHeight: CGFloat = view.bounds.height / 9
        titleLabel.frame = CGRect(x: 0, y: view.bounds.height - (titleLabelHeight * 2), width: view.bounds.width, height: titleLabelHeight)
    }
    
    func customSetup(_ title: String, imageName: String) {
        
        self.titleString = title
        self.imageName = imageName
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
