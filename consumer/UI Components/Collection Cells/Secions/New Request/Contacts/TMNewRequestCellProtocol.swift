//
//  TMNewRequestCellProtocol.swift
//  consumer
//
//  Created by Gregory Sapienza on 3/20/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Foundation

/// Delegate to control sizing of objects that implement the TMNewRequestCellProtocol.
protocol TMRequestCellSizeProtocol {
    
    /// Size of the cell did update.
    ///
    /// - Parameter indexPath: Index path
    func sizeDidUpdate(_ indexPath: IndexPath)
}

protocol TMNewRequestCellProtocol {
    associatedtype BodyView: Layout
    associatedtype BodyViewData
     
    /// Title label represented cell.
    var titleLabel: UILabel { get set }
    
    /// Subtitle label represented in cell.
    var subtitleLabel: UILabel { get set }
    
    /// Title string to use in title label. Use this to set the label text.
    var title: String? { get set }
    
    /// Subtitle string to use in the subtitle label. Use this to set the subtitle label text.
    var subtitle: String? { get set }
    
    /// Minimum possible height of cell. This will only contain the title label.
    static var minimumHeight: CGFloat { get }
    
    /// Body content of cell under title.
    var bodyView: BodyView { get set }
    
    /// Index path of the cell inside a collection or table view.
    var indexPath: IndexPath! { get set }
    
    /// Responds to cell content height size changes.
    var sizeDelegate: TMRequestCellSizeProtocol? { get set }
    
    /// Performs calculation on what the cell height should be to fit.
    ///
    /// - Parameters:
    ///   - cellWidth: Width of cell.
    ///   - bodyViewData: Data to use for calculation.
    ///   - minHeight: Minimum height, we dont want the cell to be any smaller than this.
    /// - Returns: Value of cell height based on data.
    static func calculatedCellHeight(cellWidth: CGFloat, bodyViewData: BodyViewData, minHeight: CGFloat) -> CGFloat
}

// MARK: - TMNewRequestCellProtocol Extension
extension TMNewRequestCellProtocol {
    static var minimumHeight: CGFloat {
        get {
            return 84
        }
    }
    
    /// String to use in the title label. Set this instead of the label directly. Setting the title text will add necessary attributes.
    var title: String? {
        set {
            let attributedString = NSMutableAttributedString(string: newValue?.uppercased() ?? "")
            attributedString.addAttribute(NSKernAttributeName, value: 0.5, range: NSMakeRange(0, newValue?.length ?? 0))
            titleLabel.attributedText = attributedString
        }
        
        get {
            return titleLabel.text
        }
    }
    
    /// String to use in the subtitle label. Set this instead of the label directly. Setting the subtitle text will add necessary attributes.
    var subtitle: String? {
        set {
            let attributedString = NSMutableAttributedString(string: newValue?.uppercased() ?? "")
            attributedString.addAttribute(NSKernAttributeName, value: 0.5, range: NSMakeRange(0, newValue?.length ?? 0))
            subtitleLabel.attributedText = attributedString
        }
        
        get {
            return subtitleLabel.text
        }
    }
    
    /// Lays out title label, subtitle label and body view in a standard set layout.
    ///
    /// - Parameter bounds: Bounds where to lay out title label, subtitle label and body view.
    func layoutField(in bounds: CGRect) {
        var layout = NewRequestFieldLayout(title: titleLabel, subtitle: subtitleLabel, body: bodyView)
        layout.layout(in: bounds)
    }
    
    /// Generates a title label to use in cell.
    ///
    /// - Returns: Label representing title label.
    func generateTitleLabel() -> UILabel {
        let label = UILabel()
        
        label.textAlignment = .center
        label.textColor = UIColor.TMColorWithRGBFloat(155, green: 155, blue: 155, alpha: 1)
        label.font = UIFont.MalloryBook(12)
        
        return label
    }
    
    /// Generates a subtitle label to use in cell.
    ///
    /// - Returns: Label representing subtitle label.
    func generateSubtitleLabel() -> UILabel {
        let label = UILabel()
        
        label.textAlignment = .center
        label.textColor = UIColor.TMColorWithRGBFloat(193, green: 193, blue: 193, alpha: 1)
        label.font = UIFont.MalloryBook(12)
        
        return label
    }
}
