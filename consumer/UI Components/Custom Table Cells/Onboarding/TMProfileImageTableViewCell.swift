//
//  TMProfileImageTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 6/13/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

protocol TMProfileImageTableViewCellDelegate {
    func profileImageButtonPressed(_ sender: AnyObject)
}

class TMProfileImageTableViewCell: UITableViewCell {

    // Delegate
    var delegate: TMProfileImageTableViewCellDelegate?
    
    // Action button
    @IBOutlet var profileImageButton: UIButton!
    
    // User
    var user: TMUser! {
        didSet {
            guard let _user = user else {
                return
            }
            
            profileView.user = _user
        }
    }
    
    // Profile image
    var profileImage: UIImageView! {
        
        return profileView.bowImageView
    }
    var profileView: TMProfileContactView!
    
    @IBAction func profileImageButtonPressed(_ sender: AnyObject) {
        self.delegate?.profileImageButtonPressed(sender)
    }    
}
