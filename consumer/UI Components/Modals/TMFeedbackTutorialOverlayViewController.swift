//
//  TMFeedbackTutorialOverlayViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/31/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMFeedbackTutorialOverlayViewController: UIViewController {
    
    /// Checkmark button
    @IBOutlet weak var checkmarkButton: UIButton!
    
    /// Description text
    @IBOutlet weak var copyLabel: UILabel! {
        didSet {
            
            copyLabel.attributedText = generateTutorialCopy()
        }
    }
    
    /// Checkmark button selected
    var donePressed: (()->())?

    func doneSelected(completion: (()->())?) {
        
        donePressed = completion
    }
    
    @IBAction func doneButtonPressed() {
        donePressed?()
    }
    
    func generateTutorialCopy()-> NSAttributedString {
        
        /// Default copy stirng
        let tutorialCopyString = "Pick a gift (or several) and we’ll\nwrap and send it for you!\n\nStill looking for the right thing? No\nproblem! Just rate these options\nand press the ‘Find more gifts’ button."
        
        /// Spacing between lines and alignment
        let paragraph = NSMutableParagraphStyle()
        
        paragraph.lineSpacing = 5
        paragraph.alignment = .center
        
        let fontSize: CGFloat = DeviceType.IS_IPHONE_5 ? 12 : 14
        /// Parameters for attributed string
        let parameters: [String: Any] = [NSFontAttributeName: UIFont.ActaBook(fontSize), NSForegroundColorAttributeName: UIColor.TMBlackColor, NSParagraphStyleAttributeName: paragraph]
        
        let resultAttributedString = NSAttributedString(string: tutorialCopyString, attributes: parameters)
        
        return resultAttributedString
    }
}
