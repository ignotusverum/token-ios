//
//  TMWhiteListViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 10/31/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMWhiteListViewController: UIViewController {

    // Close handler
    var closeHandler: (() -> ())?
    
    // Invitation Handler
    var invitationHandler: (() -> ())?
    
    // Copy
    let copyString = "Token is available by invitation only,\nbut we would love to help you as soon\nas room opens up.\n\nIf you have already been invited,\nplease sign up with the email address\nwhere you received your invitation."
    
    // Copy Label
    @IBOutlet weak var copyLabel: UILabel!
    
    // Tutle Label
    @IBOutlet weak var titleLabel: UILabel!
    
    // Close Button
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var inviteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spacing = NSMutableAttributedString(attributedString: copyString.setCharSpacing(1.0))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        paragraphStyle.alignment = .center
        
        let attrsDict = [NSParagraphStyleAttributeName : paragraphStyle]
        
        spacing.addAttributes(attrsDict, range: NSMakeRange(0, copyString.length))
        spacing.addAttribute(NSFontAttributeName, value: UIFont.ActaBook(13.0), range: NSRange(location: 0, length: copyString.length))
        
        // Set copy attributes
        self.copyLabel.attributedText = spacing
        
        // Set title spacing
        self.titleLabel.attributedText = self.titleLabel.text?.setCharSpacing(0.6)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.inviteButton.addGradient(0)
        
        self.inviteButton.setTitleColor(UIColor.white, for: UIControlState())
    }
    
    func inviteSelected(_ completion: (()->())?) {
        
        self.invitationHandler = completion
    }
    
    func closeSelected(_ completion: (()->())?) {
        
        self.closeHandler = completion
    }
    
    // MARK: - Actions
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        
        // Passing close handler
        self.closeHandler?()
    }
    
    @IBAction func invitationButtonPressed(_ sender: UIButton) {
        
        // Passing invitation handler
        self.invitationHandler?()
    }
}
