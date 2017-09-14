//
//  TMProfileContactView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 6/23/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import AlamofireImage

class TMProfileContactView: TMContactStatusView {
    
    var user: TMUser? {
        didSet {
            
            // Safety check
            guard let _user = user else {
                return
            }
            
            self.fullNameLabel.isHidden = true
            
            if let urlString = _user.profileURLString, let URL = URL(string: urlString) {
                
                self.setupWaxAvatar(name: _user.fullName)
                
                let imageCache = AutoPurgingImageCache()
                if let image = imageCache.image(withIdentifier: urlString) {
                    
                    self.bowImageView.image = image
                }
                else if let userImage = _user.userImage{
                    
                    self.bowImageView.image = userImage
                }
                else {
                
                    self.bowImageView.af_setImage(withURL: URL, imageTransition: .crossDissolve(0.1), completion: { response-> Void in
                        
                        if let image = response.result.value {
                            
                            imageCache.add(image, withIdentifier: urlString)
                        }
                    })
                }
            }
            else {
                
                self.setupWaxAvatar(name: _user.fullName)
            }
        }
    }
}
