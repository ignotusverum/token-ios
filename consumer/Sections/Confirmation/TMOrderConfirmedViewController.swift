//
//  TMOrderConfirmedViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/26/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMOrderConfirmedViewController: TMConfirmedRequestViewController {
    
    override func setupEmptyView() {
        
        TMAnalytics.trackScreenWithID(.s15)
        
        if let name = request?.contact?.availableName {
            
            TMCopy.OrderConfirmation.replaceName = name
        }
        
        emptyStateView = TMEmptyDataset(title: TMCopy.OrderConfirmation.title, body: TMCopy.OrderConfirmation.body, topLayout: requestInfoView.frame.y + requestInfoView.frame.height + (DeviceType.IS_IPHONE_6P ? 50 : 30))
        
        view.addSubview(emptyStateView)
    }
    
    override func dismissViewController(_ sender: UIButton) {
        
        self.dismissVC(completion: nil)
        
        TMAnalytics.trackEventWithID(.t_S15_0)
    }
}
