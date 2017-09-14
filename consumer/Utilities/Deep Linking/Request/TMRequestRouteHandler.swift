//
//  TMRequestRouteHandler.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/22/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import PromiseKit
import JDStatusBarNotification

// Handles Requst flow - new request / home
class TMRequestRouteHandler {
    
    // Shared Handler
    static let sharedHandler = TMRequestRouteHandler()
    
    // Transition to index screen
    class func initialTransition() {

        let netman = TMNetworkingManager.shared
        
        if netman.accessToken != nil {
            
            TMMenuViewController.sharedMenu.dismissVC(completion: nil)
            TMDeepLinkHandler.transitionToController(TMMenuViewController.sharedMenu)
        }
    }
    
    class func statusViewForRequestID(_ requestID: String?) {
        
        guard let requestID = requestID else {
            return
        }
        
        let netman = TMNetworkingManager.shared
        
        if netman.accessToken != nil {
            
            TMMenuViewController.sharedMenu.dismissVC(completion: nil)
            
            self.recomFlow(requestID: requestID, alwaysShowRecommendations: false).then { controller-> Void in
                
                if let controller = controller {
                    
                    TMDeepLinkHandler.presentViewController(controller)
                }
                else {
                    
                    self.initialTransition()
                }
                
                }.catch { error in
                    
                    self.initialTransition()
            }
        }
    }
    
    class func conversationViewForRequestID(_ requestID: String?) {
        
        
        guard let requestID = requestID else {
            return
        }
        
        let netman = TMNetworkingManager.shared
        if netman.accessToken != nil {
            
            TMMenuViewController.sharedMenu.dismissVC(completion: nil)

            TMRequestAdapter.fetch(requestID: requestID).then { request-> Void in
                
                let requestStatusBase = TMDeepLink(storyboardID: "Recommendation", controllerID: "requestStatusNavigation")
                let conversationLink = TMDeepLink(storyboardID: "Recommendation", controllerID: "conversationViewController")
                
                let conversationController = conversationLink.controller as? TMRequestConversationViewController
                conversationController?.request = request
                conversationController?.showButtonDown = true

                let resultNavigation = TMDeepLinkHandler.buildNavigation(requestStatusBase, controllerLinks: [conversationLink])
                
                TMDeepLinkHandler.presentViewController(resultNavigation)
                }.catch { error in
                        
                    self.initialTransition()
                    print(error)
            }
        }
    }
    
    // MARK: - Fetching data for presentation + creating nav flow
    
    
    /// Request status controller - initial controller
    ///
    /// - Parameters:
    ///   - requestID: Id For Request
    ///   - alwaysShowRecommendations: Should recommendations be shown no matter the status of the request, as long as there are a few recommendations.
    /// - Returns: New view controller.
    class func recomFlow(requestID: String, alwaysShowRecommendations: Bool)-> Promise<UIViewController?> {
        
        return TMRequestAdapter.fetch(requestID: requestID).then { request-> Promise<UIViewController?> in
            
            guard let request = request else {
                return Promise(value: nil)
            }
            
            TMMenuViewController.sharedMenu.dismissVC(completion: nil)
            
            return TMRecommendationsAdapter.fetchRecommendations(request: request).then { response-> Promise<TMCart?> in
                
                return TMCartAdapter.fetchCart(request: request)
                }.then { itemsArray-> UIViewController? in
            
                    let requestStatusBase = TMDeepLink(storyboardID: "Recommendation", controllerID: "requestStatusNavigation")
                    
                    if (request.status == .selection || alwaysShowRecommendations) && request.recommendationArray.count > 0 {
                    
                        // Create request status controller
                        let requestStatusLink = TMDeepLink(storyboardID: "Recommendation", controllerID: "TMRecommendationsNavigationViewController")
                        
                        let requestController = requestStatusLink.controller as? TMRecommendationsNavigationViewController
                        
                        requestController?.isModal = true
                        requestController?.request = request
                        
                        let resultNavigation = TMDeepLinkHandler.buildNavigation(requestStatusBase, controllerLinks: [requestStatusLink])
                        
                        return resultNavigation
                    }
                    else {
                        
                        // Request Status
                        let requestStatus = TMDeepLink(storyboardID: "Recommendation", controllerID: "TMRequestStatusViewController")
                        
                        let requestStatusController = requestStatus.controller as? TMRequestStatusViewController
                        requestStatusController?.request = request
                        
                        let resultNavigation = TMDeepLinkHandler.buildNavigation(requestStatusBase, controllerLinks: [requestStatus])
                        
                        return resultNavigation
                    }
            }
        }
    }
}

