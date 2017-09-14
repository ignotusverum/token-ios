//
//  TMReachabilityManager.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/28/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import ReachabilitySwift

class TMReachabilityManager: NSObject {
    
    var reachability: Reachability?
    static let sharedManager = TMReachabilityManager()
    
    func reachabilitySetup() {
        
        self.stopNotifier()
        self.setupReachability(hostName: "google.com", useClosures: true)
        self.startNotifier()
    }
    
    func setupReachability(hostName: String?, useClosures: Bool) {
        
        if (useClosures) {
            reachability?.whenReachable = { reachability in
                DispatchQueue.main.async {
                    self.updateWhenReachable(reachability)
                }
            }
            reachability?.whenUnreachable = { reachability in
                DispatchQueue.main.async {
                    self.updateWhenNotReachable(reachability)
                }
            }
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(TMReachabilityManager.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    
    func updateWhenReachable(_ reachability: Reachability) {
        print("\(reachability.description) - \(reachability.currentReachabilityString)")
        
        let sharedView = TMNoConnectionView.sharedView
        sharedView.dismissView()
    }
    
    func updateWhenNotReachable(_ reachability: Reachability) {
        print("\(reachability.description) - \(reachability.currentReachabilityString)")
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            if !topController.isKind(of: TMSplashViewController.self) {
                
                let sharedView = TMNoConnectionView.sharedView
                sharedView.showView()
            }
        }
    }
    
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            updateWhenReachable(reachability)
        } else {
            updateWhenNotReachable(reachability)
        }
    }
    
    deinit {
        stopNotifier()
    }
}
