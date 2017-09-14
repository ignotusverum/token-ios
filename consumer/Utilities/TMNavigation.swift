//
//  TMNavigation.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/29/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

extension UINavigationBar {
    
    func hideBottomHairline()
    {
        hairlineImageViewInNavigationBar(self)?.isHidden = true
    }
    
    func showBottomHairline()
    {
        hairlineImageViewInNavigationBar(self)?.isHidden = false
    }
    
    fileprivate func hairlineImageViewInNavigationBar(_ view: UIView) -> UIImageView?
    {
        if let imageView = view as? UIImageView, imageView.bounds.height <= 1
        {
            return imageView
        }
        
        for subview: UIView in view.subviews
        {
            if let imageView = hairlineImageViewInNavigationBar(subview)
            {
                return imageView
            }
        }
        
        return nil
    }
}

extension UIToolbar
{
    
    func hideHairline()
    {
        hairlineImageViewInToolbar(self)?.isHidden = true
    }
    
    func showHairline()
    {
        hairlineImageViewInToolbar(self)?.isHidden = false
    }
    
    fileprivate func hairlineImageViewInToolbar(_ view: UIView) -> UIImageView?
    {
        if let imageView = view as? UIImageView, imageView.bounds.height <= 1
        {
            return imageView
        }
        
        for subview: UIView in view.subviews
        {
            if let imageView = hairlineImageViewInToolbar(subview)
            {
                return imageView
            }
        }
        
        return nil
    }
    
}
