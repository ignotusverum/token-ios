//
//  TMOnboardingRouteHandler.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/22/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMOnboardingRouteHandler {
    
    class func initialTransition() {

        let netman = TMNetworkingManager.shared
        
        if netman.accessToken == nil {
        
            let sb = UIStoryboard(name: "Onboarding", bundle: nil)
            let registerNavController = sb.instantiateViewController(withIdentifier: "initialNavigationController")

            TMDeepLinkHandler.transitionToController(registerNavController)
        }
    }
    
    class func loginTransition() {
        
        let netman = TMNetworkingManager.shared
        
        if netman.accessToken == nil {
        
            let base = TMDeepLink(storyboardID: "Onboarding", controllerID: "initialNavigationController")
            let tutorialLink = TMDeepLink(storyboardID: "Onboarding", controllerID: "TMLoginViewController")
            
            let resultController = TMDeepLinkHandler.buildNavigation(base, controllerLinks: [tutorialLink])
            TMDeepLinkHandler.presentNavViewController(resultController)
        }
    }
    
    class func tutorialTransition() {
        
        let netman = TMNetworkingManager.shared
        
        if netman.accessToken == nil {
        
            let base = TMDeepLink(storyboardID: "Onboarding", controllerID: "initialNavigationController")
            let tutorialLink = TMDeepLink(storyboardID: "Onboarding", controllerID: "TMTutorialViewController")
            
            let resultController = TMDeepLinkHandler.buildNavigation(base, controllerLinks: [tutorialLink])
            TMDeepLinkHandler.presentNavViewController(resultController)
        }
    }
    
    class func createAccountTransition() {
        
        let netman = TMNetworkingManager.shared
        
        if netman.accessToken == nil {
        
            let base = TMDeepLink(storyboardID: "Onboarding", controllerID: "initialNavigationController")
            let tutorialLink = TMDeepLink(storyboardID: "Onboarding", controllerID: "TMTutorialViewController")
            let createAccountLink = TMDeepLink(storyboardID: "Onboarding", controllerID: "TMCreateAccountViewController")

            let resultController = TMDeepLinkHandler.buildNavigation(base, controllerLinks: [tutorialLink, createAccountLink])
            TMDeepLinkHandler.presentNavViewController(resultController)
        }
    }
}
