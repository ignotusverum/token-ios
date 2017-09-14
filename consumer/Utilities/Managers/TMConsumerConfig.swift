//
//  TMConsumerConfig.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/1/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Stripe
import Analytics
import CoreStore
import SwiftyJSON
import PromiseKit
import EZSwiftExtensions

let TMUserDataKey = "TMUserDataKey"
let TMOnboardingModelKey = "TMOnboardingModelKey"

/// Key to check if user already saw feedback onboarding
public let TMFeebackOnBoardingKey = "TMFeebackOnBoardingKey"

class TMConsumerConfig: NSObject {
    
    static let shared = TMConsumerConfig()
    
    /// Feedback onboarding logic
    var isFeedbackOnboardingSeen: String? {
        get {
            
            let keychain = TMAppDelegate.appDelegate?.keychain
            let isFeedbackOnboardingSeenOld = keychain?[TMFeebackOnBoardingKey]
            
            return isFeedbackOnboardingSeenOld
        }
        set {
            
            let keychain = TMAppDelegate.appDelegate?.keychain
            keychain?[TMFeebackOnBoardingKey] = newValue
        }
    }
    
    var _onboardingModel: TMOnboardingModel?
    var onboardingModel: TMOnboardingModel? {
        
        get {
            
            let defaults = UserDefaults.standard
            let decoded = defaults.object(forKey: TMOnboardingModelKey) as? Data
            
            if let decoded = decoded {
                let decodedObject = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? TMOnboardingModel
                
                _onboardingModel = decodedObject
            }
            
            return _onboardingModel
        }
        set {
            
            _onboardingModel = newValue
            
            let defaults = UserDefaults.standard
            
            if let onboardingModel = _onboardingModel {
                
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: onboardingModel)
                
                defaults.set(encodedData, forKey: TMOnboardingModelKey)
                defaults.synchronize()
            }
            else {
                
                defaults.removeObject(forKey: TMOnboardingModelKey)
            }
        }
    }
    
    var _updateAvaliable: Bool?
    var updateAvaliable: Bool {
        get {
            
            if _updateAvaliable == nil {
                
                let defaults = UserDefaults.standard
                _updateAvaliable = defaults.bool(forKey: TMAppUpdateFoundKey)
            }
            
            return _updateAvaliable!
        }
        set {
            
            let defautls = UserDefaults.standard
            defautls.set(newValue, forKey: TMAppUpdateFoundKey)
            defautls.synchronize()
        }
    }
    
    var _savedAppVersion: String?
    var savedAppVersion: String? {
        get {
            
            if _savedAppVersion == nil {
                
                let defaults = UserDefaults.standard
                _savedAppVersion = defaults.object(forKey: TMAppVersionKey) as? String
            }
            
            return _savedAppVersion
            
        }
        set {
            
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: TMAppVersionKey)
            defaults.synchronize()
        }
    }
    
    
    var _lastUpdatedCheckDate: Date?
    var lastUpdatedCheckDate: Date? {
        get {
            
            let defaults = UserDefaults.standard
            let lastUpdatedDate = defaults.object(forKey: TMAppLastUpdateCheckDateKey)
            
            if lastUpdatedDate != nil {
                _lastUpdatedCheckDate = lastUpdatedDate as! Date?
            }
            else {
                _lastUpdatedCheckDate = Date(timeIntervalSince1970: 0)
            }
            
            return _lastUpdatedCheckDate
        }
        set {
            
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: TMAppLastUpdateCheckDateKey)
            defaults.synchronize()
        }
    }
    
    var _shortBundleVersion: String?
    var shortBundleVersion: String? {
        
        if _shortBundleVersion == nil {
            
            let infoDictionary = Bundle.main.infoDictionary
            let bundleVersion = infoDictionary!["CFBundleShortVersionString"] as? String
            
            _shortBundleVersion = bundleVersion
        }
        
        return _shortBundleVersion
    }
    
    var _bundleVersion: String?
    var bundleVersion: String? {
        
        if _bundleVersion == nil {
            
            let infoDictionary = Bundle.main.infoDictionary
            
            if let bundleVersion = infoDictionary?["CFBundleVersion"] as? String {
                
                _bundleVersion = bundleVersion
            }
        }
        
        return _bundleVersion
    }
    
    fileprivate var _currentUser: TMUser?
    var currentUser: TMUser? {
        set {
            
            _currentUser = newValue
            
            let defaults = UserDefaults.standard
            
            if let _currentUser = _currentUser, let id = _currentUser.id {
                
                let userID = NSKeyedArchiver.archivedData(withRootObject: id)
                defaults.set(userID, forKey: TMUserDataKey)
            }
            else {
                
                defaults.removeObject(forKey: TMUserDataKey)
            }
            
            defaults.synchronize()
        }
        get {
            
            if _currentUser?.id == nil {
                
                let defaults = UserDefaults.standard
                
                let userIDData = defaults.data(forKey: TMUserDataKey)
                
                if userIDData != nil {
                    
                    let userID = NSKeyedUnarchiver.unarchiveObject(with: userIDData!)
                    
                    if let userID = userID {
                        
                        let user = TMCoreDataManager.defaultStack.fetchOne(From<TMUser>(), Where("\(TMModelAttributes.id.rawValue) == %@", userID))
                        
                        if let user = user {
                            
                            _currentUser = user
                        }
                    }
                }
            }
            
            return _currentUser
        }
    }
    
    class func handleVersionChanges() {
        
        let analytics = SEGAnalytics.shared()
        
        let config = self.shared
        config.lastUpdatedCheckDate = Date(timeIntervalSince1970: 0)
        
        let appVersion = config.savedAppVersion
        
        let numberFormat = NumberFormatter()
        numberFormat.numberStyle = .decimal
        
        var bundleVersion = config.bundleVersion
        
        if bundleVersion == nil {
            bundleVersion = "0"
        }
        
        if appVersion != nil {
            
            let appVersionDouble = appVersion!.toDouble()
            let bundleVersionDouble = bundleVersion?.toDouble()
            
            if appVersionDouble == bundleVersionDouble {
                
                print("VERSIONING: typical launch - no change")
                analytics.track("Launch", properties: ["category" : "Config", "label": "Existing"])
            }
            else {
                
                config.savedAppVersion = bundleVersion
                
                if appVersion! < bundleVersion! {
                    
                    print(String(format: "VERSIONING: detected upgrade (%@ < %@)", appVersion!, bundleVersion!))
                    
                    config.updateAvaliable = true
                    
                    analytics.track("Launch", properties: ["category" : "Config", "label": "Upgrade"])
                    analytics.track("Application Updated", properties: ["previous_version" : appVersion!, "version": bundleVersion!, "build": ez.appBuild!])
                }
                else if (appVersion?.toInt())! > (bundleVersion?.toInt())!  {
                    
                    print(String(format: "VERSIONING: detected downgrade (%@ > %@)", appVersion!, bundleVersion!))
                    
                    analytics.track("Launch", properties: ["category" : "Config", "label": "Downgrade"])
                }
            }
            
        }
        else {
            
            print(String(format: "VERSIONING: detected fresh install %@ )", bundleVersion!))
            
            config.updateAvaliable = false
            config.savedAppVersion = bundleVersion
            
            analytics.track("Launch", properties: ["category" : "Config", "label": "Fresh_Run"])
        }
    }
    
    class func checkForUpdates(forced: Bool)-> Promise<(success: Bool, updateAvaliable: Bool, removeVersion: String?)> {
        
        // Check if version were checked in last 2 hrs
        
        let config = TMConsumerConfig.shared
        
        // Current date for check
        let currentDate = Date()
        
        // Forced update or not
        if !forced {
            
            if let lastUpdatedDate = config.lastUpdatedCheckDate {
                
                let difference = currentDate.timeIntervalSince(lastUpdatedDate)
                if difference < 2 * 60 * 60 { // 2 hrs
                    
                    return Promise(value: (true, false, config.bundleVersion))
                }
            }
        }
        
        // Result version
        var remoteVersion: String?
        
        // Networking call
        let netman = TMNetworkingManager.shared
        return netman.request(.get, path: "config/ios").then { responseJSON-> (success: Bool, updateAvaliable: Bool, removeVersion: String?) in
            
            // Getting stripe key
            if let stripe = responseJSON["stripe_publishable_key"].string {
                
                Stripe.setDefaultPublishableKey(stripe)
            }
            
            // Checking client version
            if let responseVersion = responseJSON["client_version"].string {
                
                if responseVersion != config.shortBundleVersion {
                    if !responseVersion.versionToInt().lexicographicallyPrecedes(config.shortBundleVersion!.versionToInt()) {
                        
                        config.updateAvaliable = true
                        
                        remoteVersion = responseVersion
                        
                        print("UPDATE AVALIABLE")
                        
                        let alert = UIAlertController(title: "Update Required", message: "There is an update required for Token", preferredStyle: UIAlertControllerStyle.alert)
                        
                        if TMMacroEnviroment == "Prod" {
                            
                            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action: UIAlertAction!) in
                                
                                let testFlightUrl = URL(string: "https://itunes.apple.com/us/app/token-gift-more-thoughtfully/id1106055957")
                                
                                UIApplication.shared.openURL(testFlightUrl!)
                                
                                print("update")
                            }))
                        }
                        
                        ez.runThisAfterDelay(seconds: 5.0, after: {
                            ez.topMostVC?.present(alert, animated: true, completion: nil)
                        })
                    }
                }
            }
            
            // Get privacy url and create copy
            if let urlString = responseJSON["privacy_terms_url"].string {
                
                if let url = URL(string: urlString) {
                    
                    do {
                        let data = try Data(contentsOf: url)
                        
                        TMCopy.sharedCopy.privaryHTMLCode = data.attributedString
                    }
                    catch { }
                }
            }
            
            // Get faq url and create copy
            if let urlString = responseJSON["faq_url"].string {
                
                if let url = URL(string: urlString) {
                    
                    do {
                        let data = try Data(contentsOf: url)
                        
                        TMCopy.sharedCopy.faqHTMLCode = data.attributedString
                    }
                    catch { }
                }
            }
            
            config.lastUpdatedCheckDate = Date()
            
            if remoteVersion == nil {
                remoteVersion = config.bundleVersion
            }
            
            return(true, config.updateAvaliable, remoteVersion)
        }
    }
}
