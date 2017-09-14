//
//  TMViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/29/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

import ObjectiveC

import Analytics

// Analytic titles
let CTAClickedTitle = "CTA Clicked"

import EZSwiftExtensions

extension UIViewController {
    
    // MARK: - Appearance
    
    func addNavigationImage(_ name: String) {
        
        let logo = UIImage(named: name)
        let imageView = UIImageView(image:logo)
        imageView.tintColor = UIColor.black
        self.navigationItem.titleView = imageView
    }
    
    func addTitleText(_ titleText: String, color: UIColor = UIColor.TMTitleBlackColor) {
        
        let label = UILabel()
        
        label.attributedText = titleText.setTitleAttributes(color)
        
        label.sizeToFit()
        
        self.navigationItem.titleView = label
    }
    
    // Analytics properties
    static func viewControllerFromStoryboard(_ storyboardName: String, controllerIdentifier: String)-> UIViewController {
        
        let sb = UIStoryboard(name: storyboardName, bundle: nil)
        
        return sb.instantiateViewController(withIdentifier: controllerIdentifier)
    }

    func viewControllerFromStoryboard(_ storyboardName: String, controllerIdentifier: String)-> UIViewController {
        
        return UIViewController.viewControllerFromStoryboard(storyboardName, controllerIdentifier: controllerIdentifier)
    }
        
    func showOneButtonAlertController(_ title: String, message: String, cancelButtonText: String) {
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: cancelButtonText, style: .cancel, handler:nil)
        
        alertController.addAction(alertAction)
        
        self.presentVC(alertController)
    }
    
    @IBAction func backButtonPressed(_ sender: Any?) {
        
        self.view.endEditing(true)
        
        if self.presentingViewController?.presentedViewController != nil {
            
            self.dismissVC(completion: nil)
        }
        else {
            self.popVC()
        }
    }
    
    // MARK: - Bar button setup
    func setUpChatBadgeBarButton(_ request: TMRequest?, color: UIColor = UIColor.white)-> ENMBadgedBarButtonItem? {
        
        guard let request = request else {
            
            return nil
        }
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 65.0, height: 44.0)
        
        button.setTitle("Chat", for: UIControlState())
        button.setTitleColor(color, for: UIControlState())
        button.titleLabel?.font = UIFont.MalloryMedium(15.0)
        
        let newBarButton = ENMBadgedBarButtonItem(customView: button, value: "0", request: request)
        
        navigationItem.rightBarButtonItem = newBarButton
        
        return newBarButton
    }
    
    func dismissKeyboardUpdated() {
        view.endEditing(true)
    }
}
