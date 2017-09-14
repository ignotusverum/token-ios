//
//  TMDropDownArrowView.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/8/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

class TMDropDownArrowView: UIView {
    //MARK: - Public iVars
    
    /// Color of drop down arrow.
    var arrowColor = UIColor.black {
        didSet {
            setNeedsLayout()
        }
    }
    
    //MARK: - Private iVars
    
    /// Layer displaying arrow path.
    private let arrowLayer = CAShapeLayer()
    
    //MARK: - Public

    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.clear
        
        arrowLayer.fillColor = arrowColor.cgColor
        arrowLayer.path = getDropDownArrowPath(from: bounds)
    }
    
    //MARK: - Private

    private func customInit() {
        layer.addSublayer(arrowLayer)
    }
    
    /// Creates a CGPath for a drop down arrow.
    ///
    /// - Parameter frame: Frame containing path.
    /// - Returns: Path of arrow within specified frame.
    private func getDropDownArrowPath(from frame: CGRect) -> CGPath {
        let dropDownArrowPath = UIBezierPath()
        dropDownArrowPath.move(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 1.00000 * frame.height))
        dropDownArrowPath.addLine(to: CGPoint(x: frame.minX + 0.93301 * frame.width, y: frame.minY + 0.25000 * frame.height))
        dropDownArrowPath.addLine(to: CGPoint(x: frame.minX + 0.06699 * frame.width, y: frame.minY + 0.25000 * frame.height))
        dropDownArrowPath.close()
        
        return dropDownArrowPath.cgPath
    }
}
