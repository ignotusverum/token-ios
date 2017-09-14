//
//  TMRequestNotesCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/16/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import EZSwiftExtensions

@objc protocol TMRequestNotesCollectionViewCellProtocol {
    
    /// Text view did begin editing.
    ///
    /// - Parameter textView: Text view that began editing.
    @objc optional func textNoteViewDidBeginEditing(_ textView: UITextView)
    
    
    /// Text view did end editing.
    ///
    /// - Parameter textView: Text view that ended editing.
    @objc optional func textViewDidEndEditing(_ textView: UITextView)
    
    /// Caret position in the text view did change. Cannot be optional because it contains a struct as an parameter.
    ///
    /// - Parameters:
    ///   - caretRect: New caret rect.
    ///   - textView: Text view where the caret position changed.
    func textCaretPositionChanged(caretRect: CGRect, textView: UITextView)
}

class TMRequestNotesCollectionViewCell: UICollectionViewCell, TMNewRequestCellProtocol {
    typealias BodyView = NoteTextView
    typealias BodyViewData = String
    
    // MARK: - Public iVars
    
    lazy var titleLabel: UILabel = self.generateTitleLabel()
    
    lazy var subtitleLabel: UILabel = self.generateSubtitleLabel()
    
    lazy var bodyView: BodyView = {
        let textView = NoteTextView()
        
        textView.delegate = self
        textView.font = TMRequestNotesCollectionViewCell.font
        textView.tintColor = UIColor.black
        textView.textAlignment = .center
        textView.bounces = false
        textView.backgroundColor = UIColor.clear
        textView.layoutManager.delegate = self //The layout manager delegate will allow us to set the line spacing.
        
        return textView
    }()
    
    var indexPath: IndexPath!
    
    var sizeDelegate: TMRequestCellSizeProtocol?
    
    /// Responds to changes in text view.
    var delegate: TMRequestNotesCollectionViewCellProtocol?
    
    /// Placeholder string for the text view. Setting this value will set the placeholder text with correct attributes.
    var placeholder: String! {
        set {
            bodyView.attributedPlaceholder = NSMutableAttributedString.initWithString(newValue, lineSpacing: TMRequestNotesCollectionViewCell.bodyViewLineSpacing, aligntment: .center)
        }
        
        get {
            return bodyView.placeholderText
        }
    }
    
    // MARK: - Private

    /// Line spacing for body text view.
    fileprivate static let bodyViewLineSpacing: CGFloat = 10
    
    /// Font for body text view.
    fileprivate static var font: UIFont {
        if DeviceType.IS_IPHONE_5 {
            return UIFont.ActaBook(16)
        } else {
            return UIFont.ActaBook(24)
        }
    }
    
    // MARK: - Public

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(bodyView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(bodyView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.white
        layoutField(in: bounds)
        addShadow() //Updates shadow when bounds change.
    }
    
    static func calculatedCellHeight(cellWidth: CGFloat, bodyViewData: BodyViewData, minHeight: CGFloat = 0) -> CGFloat {
        guard let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle else {
            fatalError("Paragraph style is nil.")
        }
        
        paragraphStyle.lineSpacing = bodyViewLineSpacing
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributedString = NSAttributedString(string: bodyViewData, attributes: [NSFontAttributeName : TMRequestNotesCollectionViewCell.font, NSParagraphStyleAttributeName : paragraphStyle])
        
        let newTextRect = attributedString.boundingRect(with: CGSize(width: cellWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)

        let newHeight = newTextRect.height + minimumHeight + bodyViewLineSpacing + (TMRequestNotesCollectionViewCell.font.pointSize * 2) //Accounts for the newSize of the text, minimumHeight(Title, subtitle) and spacing and text size for the next line. You may be asking why do we multiply the point size by two. No idea, the boundingRect height seems to return the wrong height in many situations and adding some extra space to the cell height will ensure that text doesnt get cut off.
        
        return newHeight > minHeight ? newHeight : minHeight //If the new height is larger than the min then use that otherwise go with the minimum height.
    }
}

// MARK: - UITextViewDelegate
extension TMRequestNotesCollectionViewCell: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.textViewDidEndEditing?(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        sizeDelegate?.sizeDidUpdate(indexPath)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textNoteViewDidBeginEditing?(textView)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let startRange = textView.selectedTextRange?.start else {
            return
        }
        
        //Update the delegate with the new caret position.
        let caretRect = textView.caretRect(for: startRange)
        delegate?.textCaretPositionChanged(caretRect: caretRect, textView: textView)
    }
}

// MARK: - NSLayoutManagerDelegate
extension TMRequestNotesCollectionViewCell: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return TMRequestNotesCollectionViewCell.bodyViewLineSpacing //This is the line spacing for the text view.
    }
}

// MARK: - NoteTextView
class NoteTextView: UITextView {
    override func caretRect(for position: UITextPosition) -> CGRect {
        var originalRect = super.caretRect(for: position)
        
        if let fontPointSize = font?.pointSize {
            originalRect.size.height = fontPointSize //When increasing line spacing, it increases the caret rect height. This sets it to a more sensible value.
        }
        
        return originalRect
    }
    
    /// Prevents text view from becoming scrollable for some reason. 🙄
    override var contentOffset: CGPoint {
        set {
            super.contentOffset = CGPoint(x: 0, y: 0)
        }
        
        get {
            return CGPoint(x: 0, y: 0)
        }
    }
    
    /// Prevents text view from having a random bottom inset that it sometimes likes to add.
    override var contentInset: UIEdgeInsets {
        set {
            super.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }

        get {
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    /// Sometimes the text view content size has been incorrect. This should fix that.
    override var contentSize: CGSize {
        set {
            super.contentSize = bounds.size
        }
        
        get {
            return bounds.size
        }
    }
}
