//
//  TMTutorialNavigationBar.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/2/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMTutorialNavigationBar: UINavigationBar {
    
    /// Overrides to provide a new height when the status bar is hidden for tutorial view. By increasing the size of the navigation bar, it will appear as if the status bar is present, without actually displaying.
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        
        let currentStatusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let standardStatusBarHeight: CGFloat = 20
        
        if currentStatusBarHeight == 0 { //If status bar is hidden.
            size.height += standardStatusBarHeight + standardStatusBarHeight / 2 //Add the status bar height + half of the height because the default origin.y is set to -10.
        } else {
            size.height += standardStatusBarHeight / 2 //Add half of the height because the default origin.y is set to -10.
        }
        
        return size
    }
}
