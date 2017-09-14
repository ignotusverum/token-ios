//
//  TMTestingHelper.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 9/22/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import JDStatusBarNotification

class TMTestingHelper: NSObject {

    class func reset() {
        
        if TMNetworkingManager.shared.accessToken != nil {
        
            TMNetworkingManager.shared.promiseLogout().then { result -> Void in
                
                // Return to initial onboarding
                TMOnboardingRouteHandler.initialTransition()
                }.catch { error in
                    
                    JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }
    }
}
