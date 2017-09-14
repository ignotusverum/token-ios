//
//  TMSliderCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/16/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import EZSwiftExtensions

protocol TMSliderCollectionViewCellDelegate {
    func stepSliderScrolledToMinValue(_ minValue: Int, maxValue: Int)
}

class TMSliderCollectionViewCell: UICollectionViewCell {
    
    var delegate: TMSliderCollectionViewCellDelegate?
    
    @IBOutlet var label: UILabel!
    @IBOutlet var slider: StepSlider?
    
    let valuesArray: NSMutableArray = ["$0-50","$50-100","$100-200","$200-500", "$500+"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        slider?.delegate = self
        
        self.slider?.maxCount = UInt(valuesArray.count)
        self.slider?.arrayOfLabelNames = self.valuesArray
        
        self.slider?.tintColor = UIColor.darkGray
        
        self.slider?.index = 2
        
        self.label.text = "$100-200"
        self.label.font = UIFont.ActaBook(48.0)
    }
}

extension TMSliderCollectionViewCell: StepSliderDelegate {
    public func stepSliderDidScrol(to index: Int) {
        
        self.label.text = self.valuesArray[index] as? String
        
        var minValue = 25
        var maxValue = 50
        
        if index != self.valuesArray.count - 1 {
            
            var string = valuesArray[index] as! String
            
            string = string.replacingOccurrences(of: "$", with: "")
            
            let array = string.components(separatedBy: "-")
            
            minValue = array[0].toInt()!
            maxValue = array[1].toInt()!
        }
        else {
            minValue = 500
            maxValue = 500
        }
        
        self.delegate?.stepSliderScrolledToMinValue(minValue, maxValue: maxValue)
    }
}
