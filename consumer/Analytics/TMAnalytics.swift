//
//  TMAnalytics.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 7/20/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

import Analytics
import Crashlytics

import EZSwiftExtensions

enum Analytics {
    
    enum Screens: String {
        
        case s0 = "Splash"
        case s1 = "Tutorial"
        case s2 = "Signup"
        case s3 = "Phone Verify"
        case s4 = "Home"
        case s5 = "Request"
        case s6 = "Request Confirmation"
        case s7 = "Recommendations"
        case s8 = "Recommendations Overview"
        case s9 = "Chat"
        case s10 = "Cart"
        case s11 = "Shipping"
        case s12 = "Note"
        case s13 = "Wrapping"
        case s14 = "Order Review"
        case s15 = "Order Confirmation"
        case s16 = "Login"
        case s17 = "Account"
        case s18 = "Profile Edit"
        case s19 = "Payments"
        case s20 = "Add Card"
        case s21 = "Addresses"
        case s22 = "Add Address"
        case s23 = "Terms"
        case s24 = "About"
        case s25 = "Progress"
        case s26 = "Contacts"
        case s27 = "Reset Password - Phone"
        case s28 = "Reset Password - Validation"
        case s29 = "Feedback"
    }
    
    enum Events {
        
        case t_S0_0, t_S0_1
        case t_S1_0, t_S1_1
        case t_S2_0, t_S2_1
        case t_S3_0, t_S3_1, t_S3_2
        case t_S4_0, t_S4_1, t_S4_2
        case t_S5_0, t_S5_1, t_S5_2, t_S5_3, t_S5_4, t_S5_5
        case t_S6_0, t_S6_1
        case t_S7_0, t_S7_1, t_S7_2, t_S7_3, t_S7_4, t_S7_5, t_S7_6, t_S7_7
        case t_S8_0, t_S8_1, t_S8_2
        case t_S10_0, t_S10_2, t_S10_3, t_S10_4
        case t_S11_0
        case t_S12_0
        case t_S13_0
        case t_S14_0, t_S14_1, t_S14_2, t_S14_3
        case t_S15_0
        case t_S29_0
    }
}

// Analytics Array =
let analyticsScreens: [Analytics.Screens] = [ .s0, .s1, .s2, .s3, .s4, .s5, .s6, .s7, .s8, .s9, .s10, .s11, .s12, .s13, .s14, .s15, .s16, .s17, .s18, .s19, .s20, .s21, .s22, .s23, .s24, .s25, .s26]

class TMAnalytics: NSObject {
    
    // Singleton
    static let sharedManager = TMAnalytics()
    
    // MARK: - Utilities
    class func trackScreenWithID(_ screenID: Analytics.Screens, properties: [String: Any] = [String: Any]()) {
        
        let analytics = SEGAnalytics.shared()
        
        var screenName = "Undefined"
        
        let screenIndex = analyticsScreens.index(of: screenID)
        if let screenIndex = screenIndex {
            screenName = analyticsScreens[screenIndex].rawValue
        }
        
        analytics.screen(screenName, properties: properties)
    }
    
    class func trackEventWithID(_ eventID: Analytics.Events, eventParams: [String: Any] = [String: Any]()) {
        
        var CTA: String?
        var screenName: String?
        var type: String?
        var text: String?
        
        var eventName = CTAClickedTitle
        var resultEventParameters = [String: Any]()
        
        switch eventID {
        case .t_S0_0:
            CTA = "Get Started"
            screenName = Analytics.Screens.s1.rawValue
            type = "Normal"
            text = "GET STARTED"
        case .t_S0_1:
            CTA = "Sign In"
            screenName = Analytics.Screens.s1.rawValue
            type = "Normal"
            text = "Sign in"
            
        case .t_S1_0:
            eventName = "Page Swiped"
            screenName = Analytics.Screens.s1.rawValue
            
            resultEventParameters = eventParams
            
        case .t_S1_1:
            CTA = "Skip Tutorial"
            screenName = Analytics.Screens.s1.rawValue
            
            text = "Skip"
            
            resultEventParameters = eventParams
            
        case .t_S2_0:
            CTA = "Back"
            screenName = Analytics.Screens.s2.rawValue
            type = "Normal"
            
        case .t_S2_1:
            CTA = "Create Account"
            screenName = Analytics.Screens.s2.rawValue
            type = "Normal"
            text = "CONTINUE"
            
        case .t_S3_0:
            
            eventName = "Account Created"
            
            screenName = Analytics.Screens.s3.rawValue
            
            resultEventParameters = eventParams
            
        case .t_S3_1:
            
            eventName = "Error"
            
            screenName = Analytics.Screens.s3.rawValue
            
            resultEventParameters = eventParams
            
        case .t_S3_2:
            CTA = "Submit Code"
            screenName = Analytics.Screens.s4.rawValue
            type = "Normal"
            text = "SUBMIT"
            
        case .t_S4_0:
            CTA = "Account"
            screenName = Analytics.Screens.s4.rawValue
            type = "Normal"
            
        case .t_S4_1:
            CTA = "Request Card"
            screenName = Analytics.Screens.s4.rawValue
            type = "Request Card"
            
            resultEventParameters = eventParams
            
        case .t_S4_2:
            CTA = "Create Request"
            screenName = Analytics.Screens.s4.rawValue
            type = "Normal"
            text = "GIVE A GIFT"
            
        case .t_S5_0:
            CTA = "Back"
            screenName = Analytics.Screens.s5.rawValue
            type = "Normal"
            
        case .t_S5_1:
            eventName = "Page Swiped"
            screenName = Analytics.Screens.s5.rawValue
            
            resultEventParameters = eventParams
            
        case .t_S5_2:
            CTA = "Access Contacts List"
            screenName = Analytics.Screens.s5.rawValue
            type = "Normal"
            text = "Chose a recepient"
            
        case .t_S5_3:
            CTA = "Submit Request"
            screenName = Analytics.Screens.s5.rawValue
            type = "Normal"
            text = "Submit"
            
        case .t_S5_4:
            eventName = "Request Created"
            
            screenName = Analytics.Screens.s5.rawValue
            
            resultEventParameters = eventParams
            
        case .t_S5_5:
            eventName = "Error"
            screenName = Analytics.Screens.s5.rawValue
            
            resultEventParameters = eventParams
            
        case .t_S6_0:
            print("WARNING: IMPLEMENT THIS")
        case .t_S6_1:
            CTA = "Closed Confirmation"
            screenName = Analytics.Screens.s6.rawValue
            type = "Normal"
            
            resultEventParameters = eventParams
            
        case .t_S7_0:
            CTA = "Access Chat"
            screenName = Analytics.Screens.s8.rawValue
            type = "Normal"
            text = "Chat"
            
            resultEventParameters = eventParams
            
        case .t_S7_1:
            eventName = "Page Swiped"
            
            screenName = Analytics.Screens.s7.rawValue
            
            resultEventParameters = eventParams
            
        case .t_S7_2:
            eventName = "Product Added"
            
            screenName = Analytics.Screens.s7.rawValue
            
            resultEventParameters = eventParams
            
        case .t_S7_3:
            CTA = "Add item to cart"
            screenName = Analytics.Screens.s7.rawValue
            type = "Normal"
            
            resultEventParameters = eventParams
            
        case .t_S7_4:
            CTA = "Selected Page"
            screenName = Analytics.Screens.s7.rawValue
            type = "Normal"
            
            resultEventParameters = eventParams
            
        case .t_S7_5:
            CTA = "Selected Overview"
            screenName = Analytics.Screens.s7.rawValue
            type = "Normal"
            
        case .t_S7_6:
            
            CTA = "Selected Cart"
            screenName = Analytics.Screens.s7.rawValue
            type = "Normal"
            
        case .t_S7_7:
            
            eventName = "Product Copied"
            screenName = Analytics.Screens.s7.rawValue
            type = "Normal"
            
            resultEventParameters = eventParams
            
        case .t_S8_0:
            CTA = "Recommendation Card"
            screenName = Analytics.Screens.s8.rawValue
            type = "Normal"
            
            resultEventParameters = eventParams
            
        case .t_S8_1:
            CTA = "Access Chat"
            screenName = Analytics.Screens.s8.rawValue
            type = "Normal"
            
            resultEventParameters = eventParams
            
        case .t_S8_2:
            CTA = "Still Looking"
            screenName = Analytics.Screens.s8.rawValue
            type = "Normal"
            
            resultEventParameters = eventParams

        case .t_S10_0:
            CTA = "Checkout"
            screenName = Analytics.Screens.s10.rawValue
            type = "Normal"
            text = "CHECK OUT"
            
        case .t_S10_2:
            CTA = "Edit Cart"
            screenName = Analytics.Screens.s10.rawValue
            type = "Normal"
            text = "Edit"
            
        case .t_S10_3:
            CTA = "Delete item from cart"
            screenName = Analytics.Screens.s10.rawValue
            type = "Normal"
            
            resultEventParameters = eventParams
            
        case .t_S10_4:
            eventName = "Product Removed"
            
            screenName = Analytics.Screens.s10.rawValue
            
            resultEventParameters = eventParams
            
        case .t_S11_0:
            CTA = "Submit Shipping Address"
            
            screenName = Analytics.Screens.s11.rawValue
            
            resultEventParameters = eventParams
            
        case .t_S12_0:
            CTA = "Submit Note"
            screenName = Analytics.Screens.s12.rawValue
            type = "Normal"
            text = "NEXT"
            
            resultEventParameters = eventParams
            
        case .t_S13_0:
            CTA = "Choose Wrapping"
            screenName = Analytics.Screens.s13.rawValue
            type = "Normal"
            
            resultEventParameters = eventParams
            
        case .t_S14_0:
            CTA = "Edit Shipping"
            screenName = Analytics.Screens.s14.rawValue
            type = "Normal"
            
            resultEventParameters = eventParams
            
        case .t_S14_1:
            CTA = "Edit Payment"
            screenName = Analytics.Screens.s14.rawValue
            type = "Normal"
            
            resultEventParameters = eventParams
            
        case .t_S14_3:
            CTA = "Pricing Info"
            screenName = Analytics.Screens.s14.rawValue
            type = "Normal"
            
            resultEventParameters = eventParams
            
        case .t_S14_2:
            eventName = "Checkout Completed"
            
            screenName = Analytics.Screens.s14.rawValue
            
            resultEventParameters = eventParams
            
        case .t_S15_0:
            CTA = "Closed Confirmation"
            screenName = Analytics.Screens.s15.rawValue
            type = "Normal"
            
        case .t_S29_0:
            eventName = "Recommendation Feedback Submitted"
            screenName = Analytics.Screens.s29.rawValue
            
            resultEventParameters = eventParams
        }
        
        if let screen = screenName {
            resultEventParameters["category"] = screen
        }
        
        if let type = type {
            resultEventParameters["type"] = type
        }
        
        if let text = text {
            resultEventParameters["text"] = text
        }
        
        if let CTA = CTA {
            resultEventParameters["label"] = CTA
        }
        
        SEGAnalytics.shared().track(eventName, properties: resultEventParameters)
    }
    
    class func trackingIdentity() {
        
        let config = TMConsumerConfig.shared
        let user = config.currentUser
        
        // Checking for user data
        if let user = user {
            
            let traitsDict = self.traitsDict()
            let crashlytics = Crashlytics.sharedInstance()
            
            // User ID
            crashlytics.setUserIdentifier(user.id)
            
            // Crashlytics user name
            crashlytics.setUserName(user.fullName)
            
            if let email = user.email {
                
                // Crashlytics email
                crashlytics.setUserEmail(email)
            }
            
            // Identitiy seg analytics
            SEGAnalytics.shared().identify(user.id, traits: traitsDict)
        }
    }
    
    class func traitsDict()-> [String: Any] {
        
        var traitsDict = [String: Any]()
        
        let config = TMConsumerConfig.shared
        let user = config.currentUser
        
        // Checking for user data
        if let user = user {
            
            traitsDict["name"] = user.fullName
            
            if let firstName = user.firstName {
                
                traitsDict["first_name"] = firstName
            }
            
            if let lastName = user.lastName {
                
                traitsDict["last_name"] = lastName
            }
            
            if let createdAt = user.createdAt {
                
                traitsDict["created"] = createdAt
            }
            
            if let email = user.email {
                
                // Traits email
                traitsDict["email"] = email
            }
            
            if let userName = user.userName {
                
                traitsDict["username"] = userName
            }
            
            if let phone = user.phoneNumberFormatted {
                
                traitsDict["phone"] = phone
            }
            
            traitsDict["deviceID"] = UIDevice.idForVendor()
        }
        
        return traitsDict
    }
    
    class func firstInstall() {
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "firstLaunch") == nil {
            
            SEGAnalytics.shared().track("Application Installed", properties: ["version": ez.appVersion!, "build": ez.appBuild!])
            
            defaults.set(Date(), forKey: "firstLaunch")
        }
        
        defaults.synchronize()
    }
}
