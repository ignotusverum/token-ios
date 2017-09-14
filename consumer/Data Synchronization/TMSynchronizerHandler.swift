//
//  TMSynchronizerHandler.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/18/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import SVProgressHUD

let TMSynchronizerHandlerSynchronizedNotificationKey = "TMSynchronizerHandlerSynchronizedNotificationKey"

class TMSynchronizerHandler: NSObject, TMSynchronizerAdapterDelegate {

    // MARK: - Properties
    
    var showProgress = false
    
    var dataAdaptersArray: Array<TMSynchronizerAdapter>?
    
    static let sharedSynchronizer = TMSynchronizerHandler()
    
    var synchronized: Bool = false
    
    // MARK: - Synchronization logic
    // synchronizing all adapters
    func resynchronize(_ type: SynchronizationType) {
        
        self.synchronized = false
        
        guard let _dataAdaptersArray = self.dataAdaptersArray else {
            
            return
        }
        
        if _dataAdaptersArray.count > 0 {
            for adapter in _dataAdaptersArray {
                
                if adapter.synchronizationType == type {
                    adapter.synchronizeData()
                }
                else {
                    
                    adapter.synchronized = true
                }
            }
        }
    }
    
    func addAdapter(_ adapter: TMSynchronizerAdapter) {
        
        if self.dataAdaptersArray != nil {
        
            adapter.delegate = self
            self.dataAdaptersArray!.append(adapter)
        }
    }
    
    func adapterDidSynchronized(_ adapter: TMSynchronizerAdapter) {
        
        guard let _dataAdaptersArray = self.dataAdaptersArray else {
            
            return
        }
        
        var synchronized = true
        
        if self.showProgress {
            SVProgressHUD.setBackgroundColor(UIColor.black)
            SVProgressHUD.show()
        }
        
        if _dataAdaptersArray.count > 0 {
            
            for adapter in _dataAdaptersArray {
                if !adapter.synchronized {
                    synchronized = false
                }
                
                print("--------------------")
                print(adapter, adapter.synchronized)
            }
        }
        
        self.synchronized = synchronized
        
        if self.synchronized {
            
            SVProgressHUD.dismiss()
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: TMSynchronizerHandlerSynchronizedNotificationKey), object: nil)
        }
    }
}
