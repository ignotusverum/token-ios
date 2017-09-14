//
//  TMCopyLabel.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/25/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

protocol TMCopyLabelDelegate {
    func labelCopied(_ label: TMCopyLabel)
}

class TMCopyLabel: UILabel {

    var delegate: TMCopyLabelDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit() 
    }
    
    func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(TMCopyLabel.showMenu(_:))))
    }
    
    func showMenu(_ sender: AnyObject?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        board.string = text
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
        
        self.delegate?.labelCopied(self)
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
}
