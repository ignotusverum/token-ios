//
//  TMTotalTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 6/3/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMTotalTableViewCell: UITableViewCell {

    var total: NSNumber? {
        didSet {
            guard let total = total else {
                return
            }

            priceLabe.text = String(format: "$%.2f", total.floatValue)
        }
    }
    
    // Line item name label
    @IBOutlet weak var nameLabel: UILabel!
    
    // Line item price label
    @IBOutlet weak var priceLabe: UILabel!
}
