//
//  TMDeepLinkParser.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 8/22/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import EZSwiftExtensions

let TMInternalURL = "tkn://"

// Path for parsing
struct TMDeepLinkPath {
    
    var pathString: String
    var objectID: String?
    var action: String?
    
    init(pathString: String, objectID: String?, action: String? = nil) {
        
        self.pathString = pathString
        self.objectID = objectID
        self.action = action
    }
}

class TMDeepLinkParser: NSObject {
    
    // Shared parser
    static var sharedParser = TMDeepLinkParser()
    
    var closuresArray: [String: (_ objectID: String?, _ action: String?)->()] = [:]
    
    // Parse path
    func parsePath(_ path: TMDeepLinkPath, resultFound: ((_ objectID: String?, _ action: String?)-> ())?) {
        
        // Checking all initialized paths
        for (_, key) in closuresArray.keys.enumerated() {
            
            if path.pathString == key {
                
                // Run closure associated with path
                let closure = closuresArray[key]
                closure?(path.objectID, path.action)
            }
        }
    }
    
    // Initializing path string with closure
    func path(_ string: String, resultFound: ((_ objectID: String?, _ action: String?) -> ())?) {
        
        if let resultFound = resultFound {
            
            self.closuresArray[string] = resultFound
        }
    }
    
    // Handle path url
    class func handlePathURL(_ url: URL?, completion: ((_ objectID: String?, _ action: String?)-> Void)?) {
        
        guard let url = url else {
            
            completion?(nil, nil)
            return
        }
    
        ez.runThisAfterDelay(seconds: 0.1, after: {
            // Using absolute string path
            self.handlePath(url.absoluteString, completion: completion)
        })
    }
    
    // Handle path string
    class func handlePath(_ string: String?, completion: ((_ objectID: String?, _ action: String?)-> Void)?) {
        
        let parser = self.sharedParser
        
        guard let string = string else {
            
            completion?(nil, nil)
            return
        }
        
        // Extracting path
        let resultPath = TMDeepLinkParser.extractPathFromString(string)
        
        if let resultPath = resultPath {
            
            parser.parsePath(resultPath, resultFound: completion)
            return
        }
        
        completion?(nil, nil)
        return
        // Couldn't parse - handle later
    }
    
    // MARK: - Utilities
    class func extractPathFromString(_ string: String)-> TMDeepLinkPath? {
        
        let resultString = self.getCleanPath(string)
        
        var action = ""
        var section = ""
        var objectID = ""
        
        // Cleaning path from params
        let arrayForPath = resultString.components(separatedBy: "/")
        if arrayForPath.count > 0 {
            section = arrayForPath.first!
        }
        
        if arrayForPath.count >= 1 {
            
            objectID = arrayForPath[1]
        }
        
        if arrayForPath.count > 2 {
            
            action = arrayForPath[2]
        }
        
        // Creating path
        let path = TMDeepLinkPath(pathString: section, objectID: objectID, action: action)
        
        return path
    }
    
    class func getCleanPath(_ string: String)-> String {
        
        // Checking for local internal utl - tkn://
        if string.contains(TMInternalURL) {
            
            // Removing Base URL
            return string.replacingOccurrences(of: TMInternalURL, with: "")
        }
        
        return string
    }
    
    // MARK: - Parsing notification dict
    
    class func getDeeplinkPathFrom(_ userInfo: [AnyHashable: Any])-> String? {
        
        // Handle transitions here, check for synch loading state
        guard let dataDict = userInfo["aps"] as? [String: Any]  else {
            
            return nil
        }
        
        guard let customData = dataDict["custom_data"] as? [String: Any] else {
            
            return nil
        }
        
        guard let userInfo = customData["token_action"] else {
            
            return nil
        }
        
        return userInfo as? String
    }
}
