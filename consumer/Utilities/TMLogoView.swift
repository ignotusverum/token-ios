//
//  TMLogoView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 7/5/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMLogoView: UIView {

    override func draw(_ recg: CGRect) {
        TMLogo.drawLogo(frame: self.bounds, resizing: .aspectFit)
    }
}
