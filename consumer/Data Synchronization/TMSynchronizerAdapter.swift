//
//  TMSynchronizerAdapter.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/19/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

protocol TMSynchronizerAdapterDelegate {
    
    func adapterDidSynchronized(_ adapter: TMSynchronizerAdapter)
}

enum SynchronizationType {
    
    case all
    case main
    case request
}

class TMSynchronizerAdapter: NSObject {

    // MARK: - Delegates
    var delegate: TMSynchronizerAdapterDelegate?
    
    // MARK: - Properties
    var synchronized = false
    
    var updateNotificationKey: String?
    
    var synchronizationType: SynchronizationType = .all
    
    init(type: SynchronizationType) {
        super.init()
        
        self.synchronizationType = type
    }
    
    // MARK: - Initialization methods
    
    class func modelName()-> String {
        
        return ""
    }
    
    class func updatedNotificationKey()-> String {
        
        return String(format: "TMSynchronizerAdapterUpdateNotificationFor%@", self.modelName())
    } 
    
    class func postUpdateNoticiation(_ objectID: String?) {
        
        guard let _objectID = objectID else {
            
            print("objectID in update call is nil")
            return
        }
        
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.updatedNotificationKey()), object: nil, userInfo: ["objectID": _objectID])
    }
    
    // MARK: - Synchronization logic 
    
    func synchronizeData() {
        
        self.synchronized = true
        
        if self.delegate != nil {
            self.delegate?.adapterDidSynchronized(self)
        }
    }
}
