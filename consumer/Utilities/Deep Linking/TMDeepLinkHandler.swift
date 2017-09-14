//
// TMDeepLinkHandler.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/16/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

let TMInternalUrlLoadingKey = "TMInternalUrlLoadingKey"

struct TMDeepLink {
    
    var storyboardID: String
    var controllerID: String
    
    var controller: UIViewController
    
    init(storyboardID: String, controllerID: String) {
        
        self.storyboardID = storyboardID
        self.controllerID = controllerID
        
        let sb = UIStoryboard.init(name: storyboardID, bundle: nil)
        self.controller = sb.instantiateViewController(withIdentifier: controllerID)
    }
}

class TMDeepLinkHandler: NSObject {

    // Shared handler
    static let sharedHandler = TMDeepLinkHandler()
    
    // MARK: - Initialization
    class func registerDeepLinkHanderWithUrl(_ deepLinkURL: String) { }
    
    // Register Deep Link Router
    func registerRouter() {
        
        let parser = TMDeepLinkParser.sharedParser
        
        // Request URL
        parser.path("request") { objectID, action in
            
            if action == "chat" {
            
                TMRequestRouteHandler.conversationViewForRequestID(objectID)
            } else if action == "recommendations" {
                
                _ = TMRequestRouteHandler.recomFlow(requestID: objectID!, alwaysShowRecommendations: true).then(execute: { (viewController) -> Void in
                    TMDeepLinkHandler.presentViewController(viewController)
                })
                
            } else {
                
                TMRequestRouteHandler.statusViewForRequestID(objectID)
            }
        }
        
        // Onboarding URL
        parser.path("onboarding") { objectID, action in
            
            TMOnboardingRouteHandler.initialTransition()
        }
        
        parser.path("onboarding/signin") { objectID, action in
            
            TMOnboardingRouteHandler.loginTransition()
        }
        
        parser.path("onboarding/tutorial") { objectID, action in
            
            TMOnboardingRouteHandler.tutorialTransition()
        }
        
        parser.path("onboarding/signup") { objectID, action in
            
            TMOnboardingRouteHandler.createAccountTransition()
        }
    }
    
    // MARK: - Transition handlers
    class func requestFlow() {
        
        // Initial request flow transition
        TMRequestRouteHandler.initialTransition()
    }
    
    // Root controller transition
    class func transitionToController(_ viewController: UIViewController) {

        let appDelegate = TMAppDelegate.appDelegate
        
        UIView.transition(with: ((appDelegate?.window)!)!, duration: 0.2, options: .transitionCrossDissolve, animations: { () -> Void in
            
            let oldState = UIView.areAnimationsEnabled
            
            UIView.setAnimationsEnabled(false)
            
            appDelegate?.window?.rootViewController = viewController
            
            UIView.setAnimationsEnabled(oldState)
            
        }) { finished in }
    }
    
    // MARK: - Utilities
    class func buildNavigation(_ baseLink: TMDeepLink, controllerLinks: [TMDeepLink])-> UIViewController? {
        
        let baseNavigation = baseLink.controller as? UINavigationController
        
        guard let _baseNavigation = baseNavigation else {
            return nil
        }
        
        return self.buildNavigation(_baseNavigation, controllerLinks: controllerLinks)
    }
    
    class func buildNavigation(_ navigationController: UINavigationController, controllerLinks: [TMDeepLink])-> UIViewController? {
        
        var newControllers = navigationController.viewControllers
        
        for link in controllerLinks {
            
            newControllers.append(link.controller)
        }
        
        navigationController.setViewControllers(newControllers, animated: false)
        
        navigationController.isNavigationBarHidden = false
        
        return navigationController
    }
    
    class func buildMenuNavigation(_ controllerLinks: [TMDeepLink])-> UIViewController? {
        
        let menuController = TMMenuViewController.sharedMenu
        let menuNavigation = menuController.mainViewController as? UINavigationController
        
        guard let _navigationController = menuNavigation else {
            return menuController
        }
        
        return self.buildNavigation(_navigationController, controllerLinks: controllerLinks)
    }
    
    // MARK: - Transition logic
    class func presentNavViewController(_ viewController: UIViewController?) {
        
        guard let viewController = viewController else {
            return
        }
        
        self.transitionToController(viewController)
    }
    
    class func presentViewController(_ viewController: UIViewController?) {
     
        guard let viewController = viewController else {
            return
        }
        
        let appDelegate = TMAppDelegate.appDelegate
                
        appDelegate?.window?.rootViewController?.presentVC(viewController)
    }
}
