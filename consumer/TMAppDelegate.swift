//
//  TMAppDelegate.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/20/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Fabric
import Stripe
import Branch
import Analytics
import Crashlytics
import SVProgressHUD
import KeychainAccess
import UserNotifications
import EZSwiftExtensions
import IQKeyboardManagerSwift
import JDStatusBarNotification
 
let defaultStatusAlertStyle = "defaultStyle"

let TMAppWakeNotificationKey = "TMAppWakeNotificationKey" 
 
let TMCustomURLScheme = "tkn"

@UIApplicationMain
class TMAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    static let appDelegate = UIApplication.shared.delegate as? TMAppDelegate
    
    let keychain = Keychain(service: Bundle.main.bundleIdentifier!)

    var window: UIWindow?
    
    var storeURL: URL?
    
    var storedInternalURL: String?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder = false
        IQKeyboardManager.sharedManager().toolbarPreviousNextAllowedClasses.append(IQPreviousNextView.self)
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Clean keychain, if fresh install
        checkKeychain()
        
        /// Branch setup - deeplink and attribution
        
        let branch = TMMacroEnviroment == "Prod" ? Branch.getInstance() : Branch.getTestInstance()
        
        branch?.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { (params, error) in
            if error == nil {

                if let path = params?["$ios_deeplink_path"] as? String {
                    
                    let synchronizer = TMSynchronizerHandler.sharedSynchronizer
                    
                    if synchronizer.synchronized {
                        
                        TMDeepLinkParser.handlePath(path, completion: nil)
                    }
                    else {
                        
                        /// Store URL Path for deeplink
                        self.storedInternalURL = path
                    }
                }
            }
        })
        
        application.applicationSupportsShakeToEdit = true

        // Setup analytics
        setupAnalytics(launchOptions, application: application)
        
        // Setup global alert view
        setupStatusAlertView()
        
        if TMMacroEnviroment != "Prod" {
            
            BuddyBuildSDK.setup()
        }
        // Setup redirect handler
        let sharedLinkHander = TMDeepLinkHandler.sharedHandler
        sharedLinkHander.registerRouter()
        
        let netman = TMNetworkingManager.shared
        
        if netman.accessToken != nil {
            
            setupSynchronizeAdapters(launchOptions)
        }
        
        print("Token \(String(describing: netman.accessToken))")
        
        // Setup reachability
        TMReachabilityManager.sharedManager.reachabilitySetup()
        
        // Notifications
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(TMAppDelegate.loginSuccessNotification(_:)), name: NSNotification.Name(rawValue: TMNetworkingManagerLoginSuccessfulNotificationKey), object: nil)
    
        return true
    }
    
    func checkKeychain() {
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hasRunBefore") == false {
            
            let netman = TMNetworkingManager.shared
            netman.accessToken = nil
            
            // Reset baddges
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            // update the flag indicator
            userDefaults.set(true, forKey: "hasRunBefore")
            userDefaults.synchronize() // forces the app to update the NSUserDefaults
            
            return
        }
    }
    
    func setupStatusAlertView() {
        
        JDStatusBarNotification.addStyleNamed(defaultStatusAlertStyle) { style -> JDStatusBarStyle! in
            
            style?.barColor = UIColor.TMErrorColor
            style?.textColor = UIColor.white
            style?.font = UIFont.MalloryMedium(12.0)
            
            style?.animationType = .bounce
            
            return style
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        
        Branch.getInstance().continue(userActivity)
        
        return true
    }
        
    func applicationDidBecomeActive(_ application: UIApplication) {

        SVProgressHUD.dismiss()
        
        TMConsumerConfig.checkForUpdates(forced: false).catch { error in
            print(error.localizedDescription)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: TMAppWakeNotificationKey), object: nil)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        let args = ProcessInfo.processInfo.arguments
        if !args.contains(TM_UI_TEST_MODE) {
            
            SEGAnalytics.shared().track("Application Backgrounded", properties: nil)
        }
    }
    
    // Disable custom keyboard
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool {
        if extensionPointIdentifier == UIApplicationExtensionPointIdentifier.keyboard {
            return false
        }
        return true
    }
    
    func setupAnalytics(_ launchOptions: [AnyHashable: Any]?, application: UIApplication) {
        
        Fabric.with([Crashlytics.self])
        
        SEGAnalytics.setup(with: SEGAnalyticsConfiguration(writeKey: TMSegmentTrackingID))

        SEGAnalytics.debug(false)
        SEGAnalytics.shared().enable()
        
        TMConsumerConfig.handleVersionChanges()
        
        TMAnalytics.trackingIdentity()
        TMAnalytics.firstInstall()
        
        if let launchOptions = launchOptions {
            
            var state = false
            if application.applicationState == .background {
                state = true
            }
            
            var source = ""
            if let sourceApplication = launchOptions[UIApplicationLaunchOptionsKey.sourceApplication] as? String {
                source = sourceApplication
            }
            
            var url = ""
            if let urlSource = launchOptions[UIApplicationLaunchOptionsKey.url] as? URL {
                url = urlSource.absoluteString
            }
            
            SEGAnalytics.shared().track("Application Opened", properties: ["from_background": state, "referring_application": source, "url": url])
        }
    }
    
    // Notification
    func loginSuccessNotification(_ notification: Notification) {
        
        TMAnalytics.trackingIdentity()
        setupSynchronizeAdapters(nil)
    }
    
    // MARK: - internal URLs Handling
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {

        Branch.getInstance().handleDeepLink(url)
        
        return true
    }
    
    // MARK: - Memory
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        
        /// Handle memory warning
        SEGAnalytics.shared().track("Memory warning")
    }
    
    // MARK: - Push notifications
    @available(iOS 10.0, *)
    func userNotificationCenter(_ ctenter: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) { }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) { }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let path = TMDeepLinkParser.getDeeplinkPathFrom(userInfo)
        
        /// Fetch notifications
        TMNotificationAdapter.fetch().catch { error in
            print(error)
        }
        
        if let path = path {
            if application.applicationState == .inactive {
                
                let synchronizer = TMSynchronizerHandler.sharedSynchronizer
                
                if synchronizer.synchronized {
                    
                    TMDeepLinkParser.handlePath(path, completion: nil)
                }
                else {
                    
                    // Stored URL
                    self.storedInternalURL = path
                }
            }
        }
        
        completionHandler(.newData)
    }
    
    func registerForPushNotificationsAndUpdateToken() {
        let netman = TMNetworkingManager.shared
        let accessToken = netman.accessToken
        
        if accessToken != nil {
            TMPushNotificationsManager.registerForPushNotifications(UIApplication.shared)
        }   
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // Post token to register
        print("Device Token:", TMPushNotificationsManager.deviceTokenString(deviceToken))
        TMPushNotificationsManager.sendPushToken(deviceToken, success: {}) {}
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
    
    // MARK: - Adapters
    
    func setupSynchronizeAdapters(_ launchOptions: [AnyHashable: Any]?) {
        
        let synchronizeAdapter = TMSynchronizerHandler.sharedSynchronizer
        
        synchronizeAdapter.dataAdaptersArray = [TMSynchronizerAdapter]()
        
        let requestAdapter = TMRequestAdapter(type: .main)
        let paymentAdapter = TMPaymentAdapter(type: .main)
        let contactAdapter = TMContactsAdapter(type: .main)
        let addressAdapter = TMContactAddressAdapter(type: .main)
        let conversationAdapter = TMConversationAdapter(type: .main)
        let notificationAdapter = TMNotificationAdapter(type: .main)
        let requestAttributesAdapter = TMRequestAttributesAdapter(type: .main)
        
        synchronizeAdapter.addAdapter(requestAdapter)
        synchronizeAdapter.addAdapter(contactAdapter)
        synchronizeAdapter.addAdapter(addressAdapter)
        synchronizeAdapter.addAdapter(paymentAdapter)
        synchronizeAdapter.addAdapter(requestAttributesAdapter)
        synchronizeAdapter.addAdapter(conversationAdapter)
        synchronizeAdapter.addAdapter(notificationAdapter)
        
        let netman = TMNetworkingManager.shared
        
        if netman.accessToken != nil {
            
            TMUserAdapter.fetchMe().then { response-> Void in
                synchronizeAdapter.resynchronize(.main)
                
                // Launched from push
                let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
                if let notification = notification {
                    
                    let path = TMDeepLinkParser.getDeeplinkPathFrom(notification)
                    if let path = path {
                        
                        self.storedInternalURL = path
                    }
                }
                }.catch { error in
                    print(error)
            }
        }
        else {
            // Return to initial onboarding
            TMOnboardingRouteHandler.initialTransition()
        }
    }
}
