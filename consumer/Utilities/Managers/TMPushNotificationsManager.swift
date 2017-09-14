//
//  TMPushNotificationsManager.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/9/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import PromiseKit
import EZSwiftExtensions
import JDStatusBarNotification

import  UserNotifications

class TMPushNotificationsManager: NSObject {
    
    // MARK: - Push registration
    class func deviceTokenString(_ deviceToken: Data)-> String {
        
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        return tokenString
    }
    
    
    class func registerForPushNotifications(_ application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (result, error) in
              
                if error == nil {
                    
                    application.registerForRemoteNotifications()
                }
            })
        } else {
            
            let notificationSettings = UIUserNotificationSettings( types: [.badge, .sound, .alert], categories: nil)
            
            application.registerUserNotificationSettings(notificationSettings)
        }
    }
    
    class func sendPushToken(_ pushToken: Data, success: ()-> Void, failure: ()-> Void) {
        
        let pushTokenString = self.deviceTokenString(pushToken)
        
        self.registerDeviceWithToken(pushTokenString).catch { error in
            
            print(error)
        }
    }
    
    class func registerDeviceWithToken(_ token: String)-> Promise<Bool> {
        
        return Promise { fulfill, reject in
         
            let netman = TMNetworkingManager.shared
            netman.request(.post, path: "devices", parameters: ["token": token]).then { json -> Void in
                
                print(json)
                
                fulfill(true)
            }.catch { error in
                reject(error)
            }
        }
    }
}
