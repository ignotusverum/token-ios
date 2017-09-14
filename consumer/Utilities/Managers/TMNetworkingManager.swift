//
//  TMNetworkingManager.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/27/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Contacts
import Analytics
import Alamofire
import PromiseKit
import SwiftyJSON
import JDStatusBarNotification

public let TMNetworkingManagerAccessTokenKey = "TMNetworkingManagerAccessTokenKey"
public let TMNetworkingManagerLoginFailureNotificationKey = "TMNetworkingManagerLoginFailureNotificationKey"
public let TMNetworkingManagerLoginSuccessfulNotificationKey = "TMNetworkingManagerLoginSuccessfulNotificationKey"
public let TMNetworkingManagerLogoutSuccessfulNotificationKey = "TMNetworkingManagerLogoutSuccessfulNotificationKey"
public let TMNetworkingManagerRequestUnauthorizedNotificationKey = "TMNetworkingManagerRequestUnauthorizedNotificationKey"

public var _hostName = ""

let hostName = TMHostName
let hostVersion = "1.1"

let TMError = NSError(domain: hostName, code: 400, userInfo: nil)

class TMNetworkingManager: NSObject {
    
    fileprivate var isHeaderSet = false
    
    var headers = [
        "Content-Type": "application/json",
        "version": hostVersion
    ]
    
    var accessToken: String? {
        get {
            
            let keychain = TMAppDelegate.appDelegate?.keychain
            let accessTokenOld = keychain?[TMNetworkingManagerAccessTokenKey]
            
            return accessTokenOld
        }
        set {
            
            let keychain = TMAppDelegate.appDelegate?.keychain
            keychain?[TMNetworkingManagerAccessTokenKey] = newValue
            
        }
    }
    
    static let shared = TMNetworkingManager()
    
    let manager = Alamofire.SessionManager.default
    
    func configureHTTPHeader() {
        
        if self.accessToken != nil && (self.accessToken?.length)! > 0 {
            
            self.headers["Authorization"] = String(format:"bearer %@",self.accessToken!)
        }
    }
    
    // MARK: - http requests
    func handleUnauthorizedResponse() {
        
        // Redirect to initial controller
        self.promiseLogout().then { result -> Void in
            
            // Return to initial onboarding
            TMOnboardingRouteHandler.initialTransition()
            
            }.catch { error in
                
                JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
        }
    }
    
    func baseUrl() -> String {
        
        return String(format: "https://%@", hostName)
    }
    
    func URLWithPath(path: String)-> URL {
        
        let urlResult = URL(string: self.URLString(path: path))
        if let urlResult = urlResult {
            
            return urlResult
        }
        
        return URL(string: baseUrl())!
    }
    
    func URLString(path: String)-> String {
        
        return String(format: "%@/%@", self.baseUrl(), path)
    }
    
    func promiseAuthenticate(_ login: String, password: String) -> Promise<Any?> {
        
        return Promise { fulfill, reject in
            
            let plainString = "\(login):\(password)" as NSString
            let plainData = plainString.data(using: String.Encoding.utf8.rawValue)
            let base64String = String(data: plainData!, encoding: .utf8)
            
            self.manager.session.configuration.httpAdditionalHeaders = ["Authorization": "Basic " + base64String!]
            
            self.manager.request(self.URLWithPath(path: "auth"), method: .post, parameters: ["username": login, "password": password], encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseJSON { (response) -> Void in
                    
                    if response.result.isSuccess {
                        
                        if response.result.error == nil {
                            
                            let responseJSON = JSON(response.result.value!)
                            
                            if let message = responseJSON["message"].string {
                                
                                if message == "Login or password is incorrect" {
                                    
                                    let error = NSError(domain: hostName, code: 400, userInfo: responseJSON["errors"][0].dictionaryObject)
                                    
                                    reject(error)
                                    
                                    return
                                }
                            }
                            
                            if let accessToken = responseJSON["access_token"].string {
                                self.accessToken = accessToken
                            }
                            
                            fulfill(response.result.value)
                            
                        }
                        else {
                            reject(response.result.error!)
                            self.postLoginNotificaitonWithSuccess(false)
                        }
                    }
                    else {
                        reject(response.result.error!)
                        self.postLoginNotificaitonWithSuccess(false)
                    }
            }
        }
    }
    
    // Logout logic

    func promiseLogout() -> Promise<Any?> {
        
        return Promise { fulfill, reject in
            
            /// Clear DB
            TMCoreDataManager.clearDB()
            
            /// Clear Access Token
            accessToken = nil
            
            /// Clear user defaults
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            
            /// Hide badge
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            /// Clear keychain
            TMAppDelegate.appDelegate?.checkKeychain()
            
            /// Clear cookies
            clearAllCookies()
            
            TMConversationManager.shared = nil
            
            UIApplication.shared.unregisterForRemoteNotifications()
            
            // Contact clear
            TMAddressBookManager.sharedManager.localContacts = [CNContact]()
            TMAddressBookManager.sharedManager.tokenContacts = [TMContact]()
            
            // Request clear
            TMRequestAdapter.totalCount = 0
            
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: TMNetworkingManagerLogoutSuccessfulNotificationKey), object: nil)
            
            fulfill(nil)
        }
    }
    
    // MARK: - Notification
    func clearAllCookies() {
        
        let storage = HTTPCookieStorage.shared
        
        if storage.cookies != nil {
            for cookie in storage.cookies! {
                
                let domainName = cookie.domain
                let domainRange = domainName.range(of: hostName)
                
                if let _ = domainRange {
                
                    storage.deleteCookie(cookie)
                }
            }
        }
    }
    
    // Utility Methods
    
    func request(_ method: HTTPMethod, path URLString: String, parameters: [String: Any]? = nil, success: @escaping (_ response: JSON?)-> Void, failure: @escaping (_ error: Error)-> Void) {
        
        self.configureHTTPHeader()
        
        self.manager.request(self.URLWithPath(path: URLString), method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        success(json)
                    }
                case .failure(let error):
                    
                    //                    if error._userInfo[NSLocalizedDescriptionKey]?.rangeOfString("403").length == 3 {
                    //                        self.handleUnauthorizedResponse()
                    //                    }
                    //                    else {
                    failure(error)
                    //                    }
                }
        }
    }
    
    // Promise Requests
    
    func request(_ method: HTTPMethod, path URLString: String, parameters: [String: Any]? = nil) -> Promise<JSON> {
        
        self.configureHTTPHeader()
        
        return Promise { fulfill, reject in
            
            self.manager.request(self.URLWithPath(path: URLString), method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                        
                    case .success:
                        if let value = response.result.value {
                            let json = JSON(value)
                            fulfill(json)
                        }
                        
                    case .failure(let error):
                        
                        let nsError = error as NSError
                        
                        if let description = nsError.userInfo[NSLocalizedDescriptionKey] as? NSString, description.range(of: "403").length == 3 {
                            self.handleUnauthorizedResponse()
                            reject(error)
                        }
                        else {
                            
                            if let data = response.data {
                                if let response = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                                    
                                    let updatedError = NSError(domain: hostName, code: 400, userInfo: [NSLocalizedDescriptionKey: response])
                                    
                                    reject(updatedError)
                                }
                            }
                            
                            reject(error)
                        }
                    }
            }
        }
    }
    
    func upload(_ method: HTTPMethod = .post, _ URLString: String, image: UIImage)-> Promise<JSON> {
        return Promise { fulfill, reject in
            
            self.configureHTTPHeader()
            
            self.manager.upload(multipartFormData: { multipartFormData in
                
                // import image to request
                if let imageData = UIImageJPEGRepresentation(image, 0.9) {
                        
                    multipartFormData.append(imageData, withName: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
                }
                
            }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: self.URLWithPath(path: URLString), method: method, headers: headers, encodingCompletion: { response in
                
                print(response)
                switch response {
                    
                case .success(let upload, _, _):
                    
                    upload.responseJSON { response in
                        
                        print("JSON: \(response)")
                        fulfill(JSON(response))
                    }
                    
                case .failure(let error):
                    
                    reject(error)
                }
            })
        }
    }
    
    // Notifications
    func postLoginNotificaitonWithSuccess(_ success: Bool) {
        
        let nc = NotificationCenter.default
        
        if success {
            nc.post(name: Notification.Name(rawValue: TMNetworkingManagerLoginSuccessfulNotificationKey), object: nil)
        }
        else {
            nc.post(name: Notification.Name(rawValue: TMNetworkingManagerLoginFailureNotificationKey), object: nil)
        }
    }
}
