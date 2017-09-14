//
//  TMSplashViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/27/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

import SVProgressHUD

import EZSwiftExtensions

class TMSplashViewController: UIViewController {

    var internalURLString: String?
    
    // MARK: - View Controller Lifecycle
    var radiantWave: TMLogoAnimationView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.radiantWave = TMLogoAnimationView.init(containerView: self.view, numberOfLines: 48, linesColor: UIColor.white, linesWidth: 0.7, linesHeight: 200.0)
        
        self.radiantWave!.show()
        
        self.view.sendSubview(toBack: self.radiantWave!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(TMSplashViewController.dataSourceLoadedWithNotification(_:)), name: NSNotification.Name(rawValue: TMSynchronizerHandlerSynchronizedNotificationKey), object: nil)
        
        SVProgressHUD.setDefaultMaskType(.black)
        
        let manager = TMNetworkingManager.shared
        if manager.accessToken != nil {
            
            UIView.animate(withDuration: 0.1, animations: { void in
                
                if self.radiantWave != nil {
                    
                    self.radiantWave!.alpha = 1.0
                }
            })
        }
        else {
            
            // Return to initial onboarding
            TMOnboardingRouteHandler.initialTransition()
        }
    }
    
    @IBAction func partyMode() {
        
        self.radiantWave?.disco(true)
    }
    
    // Shaking overriding
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            
            self.radiantWave?.disco(true)
        }
    }
    
    // MARK: - Notificaitons
    
    func dataSourceLoadedWithNotification(_ notification: Notification?) {
        
        let netman = TMNetworkingManager.shared
        
        if netman.accessToken != nil {
        
            let appDelegate = TMAppDelegate.appDelegate
            
            if let internalURLString = appDelegate?.storedInternalURL {
                
                // Transition to requets flow
                TMDeepLinkHandler.requestFlow()
                
                ez.runThisAfterDelay(seconds: 1, after: {
                    
                    TMDeepLinkParser.handlePath(internalURLString, completion: nil)
                    
                    appDelegate?.storedInternalURL = nil
                })
            }
            else {
             
                // Transition to requets flow
                TMDeepLinkHandler.requestFlow()
            }
        }
    }
    
    // MARK: - Utility
    func transitionToInitialController() {
        let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let nextController = onboardingStoryboard.instantiateViewController(withIdentifier: "initialNavigationController")
        
        let snapshot:UIView = (self.view.window?.snapshotView(afterScreenUpdates: true))!
        nextController.view.addSubview(snapshot)
        
        self.view.window?.rootViewController = nextController;
        
        UIView.animate(withDuration: 0.3, animations: { () in
            snapshot.layer.opacity = 0
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
            }, completion: { (value: Bool) in
                snapshot.removeFromSuperview()
        });
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

extension UINavigationController {
    
    open override var childViewControllerForStatusBarHidden : UIViewController? {
        return visibleViewController
    }
    
    open override var childViewControllerForStatusBarStyle : UIViewController? {
        return visibleViewController
    }
}
