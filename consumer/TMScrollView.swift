//
//  TMScrollView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 10/21/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit

class TMScrollView: UIScrollView {

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}
