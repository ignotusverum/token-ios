//
//  LayoutTest.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/16/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

class LayoutTest: Layout {
    var rect = CGRect.zero
    
    func layout(in rect: CGRect) {
        self.rect = rect
        print(rect)
    }
}
