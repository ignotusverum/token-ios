//
//  TMLayoutTextField.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 9/6/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMLayoutTextField: UITextField {

    @IBInspectable
    var iPhone5: CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 568 {
                self.font = self.font!.withSize(iPhone5)
            }
        }
    }
    
    @IBInspectable
    var iPhone6: CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 667 {
                self.font = self.font!.withSize(iPhone6)
            }
        }
    }
    
    @IBInspectable
    var iPhone6p: CGFloat = 0 {
        didSet {
            if UIScreen.main.bounds.maxY == 736 {
                self.font = self.font!.withSize(iPhone6p)
            }
        }
    }
}
