//
//  PingThread.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/4/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class PingThread : NSThread {
    
    var pingTaskIsRunning = false
    var semaphore = dispatch_semaphore_create(0)
    override func main() {
    while !self.cancelled {
        
        pingTaskIsRunning = true
        
        dispatch_async(dispatch_get_main_queue()) {
        self.pingTaskIsRunning = false
        dispatch_semaphore_signal(self.semaphore) }
        NSThread.sleepForTimeInterval(0.4)
        
        if pingTaskIsRunning {
        print("YOYOOYYO")
        }
        dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER)
        }
    }
}