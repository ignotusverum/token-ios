//
//  TMPaymentInputTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/25/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMPaymentInputTableViewCell: TMPaymentTableViewCell {

    // Text Field
    var textField: TMPaymentTextField!
    
    // Separator View
    @IBOutlet weak var separatorView: UIView!
    
    // Style
    override var lightStyle: Bool {
        didSet {
            
            if self.textField != nil {
                self.textField.lightStyle = self.lightStyle
                
                if lightStyle {
                    self.textField.attributedPlaceholder = NSAttributedString(string:self.textField.placeholder!,
                                                                          attributes:[NSForegroundColorAttributeName: lightColor])
                }
                else {
                    self.textField.attributedPlaceholder = NSAttributedString(string:self.textField.placeholder!,
                                                                              attributes:[NSForegroundColorAttributeName: darkColor])
                }
            }
            
            if lightStyle {
                
                self.separatorView.backgroundColor = lightColor
                
            }
            else {
                
                self.separatorView.backgroundColor = darkColor
            }
        }
    }
}
