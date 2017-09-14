//
//  TMImageView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/19/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import AlamofireImage

extension UIImageView {
    
    func downloadImageFrom(link URL: URL?, contentMode: UIViewContentMode) {
        
        self.downloadImageFrom(link: URL, frame: self.frame, contentMode: contentMode)
    }
    
    func downloadImageFrom(link url: URL?, frame: CGRect, contentMode: UIViewContentMode) {
        
        let imageCache = AutoPurgingImageCache()
        let placeholderImage = UIImage(named: "Placeholder")
        
        if let url = url {
        
            let width: Int = Int(frame.width)
            let height: Int = Int(frame.height)
            
            if let image = imageCache.image(withIdentifier: url.absoluteString) {
                
                self.image = image
            }
            else {
                guard let updatedURL = URL(string: "\(url.absoluteString)?w=\(width)&h=\(height)") else {
                    return
                }
                
                self.af_setImage(withURL: updatedURL, placeholderImage: placeholderImage!,imageTransition: .crossDissolve(0.1), completion: { response-> Void in
                  
                    if let image = response.result.value {
                        
                        imageCache.add(image, withIdentifier: url.absoluteString)
                    }
                })
            }
        }
        
        self.contentMode = contentMode
        
        self.clipsToBounds = true
    }
    
    func makeCircleImage() {
        
        if self.layer.cornerRadius != self.frame.height / 2 {
            
            self.layer.borderWidth = 1
            self.layer.masksToBounds = false
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.cornerRadius = self.frame.height / 2
            self.clipsToBounds = true
        }
    }
}
