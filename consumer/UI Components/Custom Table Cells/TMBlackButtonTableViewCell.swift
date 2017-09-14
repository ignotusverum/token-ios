//
//  TMBlackButtonTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 6/10/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

protocol TMBlackButtonTableViewCellDelegate {
    func blackButtonPressed(_ sender: UIButton)
}

class TMBlackButtonTableViewCell: UITableViewCell {
    
    // Delegate
    var delegate: TMBlackButtonTableViewCellDelegate?
    
    // Button title
    var buttonTitleString: String? {
        didSet {
            // Safety check
            guard let _buttonTitleString = buttonTitleString else {
                return
            }
            
            // Set button title
            self.button.setTitle(_buttonTitleString, for: .normal)
        }
    }
    
    // Button
    @IBOutlet var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
    // Actions
    @IBAction func buttonPressed(_ sender: UIButton) {
        self.delegate?.blackButtonPressed(sender)
    }
}
