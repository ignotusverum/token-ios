//
//  TMString.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/1/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import NSString_RemoveEmoji

extension String {
    
    var containsWhitespace : Bool {
        return(self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
    
    var utf8Data: Data? {
        return data(using: String.Encoding.utf8)
    }
    
    var composedCount : Int {
        var count = 0
        enumerateSubstrings(in: startIndex..<endIndex, options: .byComposedCharacterSequences) {_ in count = count + 1}
        return count
    }
    
    var NoWhiteSpace : String {
        
        var string = self
        
        if string.contains(" "){
            
            string =  string.replacingOccurrences(of: " ", with: "")
        }
        
        return string
    }
    
    func contains(_ find: String) -> Bool {
        
        return self.lowercased().range(of: find.lowercased()) != nil
    }
    
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont, spacing: CGFloat = 0) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName : paragraphStyle], context: nil)
        
        return boundingBox.height
    }
    
    func versionToInt() -> [Int] {
        return self.components(separatedBy: ".")
            .map {
                Int.init($0) ?? 0
        }
    }
    
    func setCharSpacing(_ spacing: Float)-> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSRange(location: 0, length: self.length))
        
        return attributedString
    }
    
    func setPlaceholder()-> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(attributedString: self.setCharSpacing(1.0))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.TMColorWithRGBFloat(155.0, green: 155.0, blue: 155.0, alpha: 1.0), range: NSRange(location: 0, length: self.length))
        
        return attributedString
    }
    
    func setTitleAttributes(_ color: UIColor)-> NSAttributedString {
        
        let attributedString = NSMutableAttributedString.initWithString(self, lineSpacing: 5.0, aligntment: .center)
        
        attributedString.addAttribute(NSKernAttributeName, value: UIFont.titleSpacing, range: NSRange(location: 0, length: self.length))
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.MalloryMedium(UIFont.titleFont), range: NSRange(location: 0, length: self.length))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location: 0, length: self.length))
        
        return attributedString
    }
    
    func with(lineSpacing: CGFloat, alignment: NSTextAlignment)-> NSMutableAttributedString {
     
        return NSMutableAttributedString(string: self, lineSpacing: lineSpacing, alignment: alignment)
    }
}

extension NSAttributedString {
    
    func changeTextColor(_ color: UIColor)-> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(attributedString: self)
        
        attributedString.addAttributes([NSForegroundColorAttributeName: color], range: NSMakeRange(0, attributedString.length))
        
        return attributedString
    }
    
    func heightWithConstrainedWidth(_ width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func widthWithConstrainedHeight(_ height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension NSMutableAttributedString {
    
    func setColorForStr(_ textToFind: String, color: UIColor) {
        
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive);
        if range.location != NSNotFound {
            
            self.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
        }
    }
    
    func setColorForRange(_ rangeToFind: NSRange, color: UIColor) {
        
        self.addAttribute(NSForegroundColorAttributeName, value: color, range: rangeToFind)
    }
    
    func setFontForStr(_ textToFind: String, font: UIFont) {
        
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive);
        if range.location != NSNotFound {
            self.addAttribute(NSFontAttributeName, value: font, range: range);
        }
    }
    
    static func initWithString(_ string: String, lineSpacing: CGFloat, aligntment: NSTextAlignment)-> NSMutableAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = aligntment
        
        let attrsDict : NSDictionary =  [NSParagraphStyleAttributeName : paragraphStyle]
        
        return NSMutableAttributedString(string: string, attributes: attrsDict as? [String : AnyObject])
    }
    
    convenience init(string: String?, lineSpacing: CGFloat, alignment: NSTextAlignment) {
    
        guard let string = string else {
            self.init(string: "")
            return
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        
        let attrsDict =  [NSParagraphStyleAttributeName : paragraphStyle]
        
        self.init(string: string, attributes: attrsDict)
    }
}

extension Data {
    var attributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
