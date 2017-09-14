//
//  TMTokenContactsCellHeader.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 7/29/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMTokenContactsCellHeader: UITableViewHeaderFooterView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView(frame: self.bounds)
        backgroundView.backgroundColor = UIColor.white
        self.backgroundView = backgroundView
    }
}
