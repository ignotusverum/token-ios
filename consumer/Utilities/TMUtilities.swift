//
//  TMUtilities.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/1/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMUtilities: NSObject {

    class func getRequestParamsWithDictionary(_ dictionary: [String: Any?])-> [String: Any]? {
        
        var resultDictionary = [String: Any]()
        
        for (key, value) in dictionary {
            
            if value != nil {
                
                resultDictionary[key] = value
            }
        }
        
        return resultDictionary
    }
}

extension Date {
    
    func yearsFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year!
    }
    
    func monthsFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month!
    }
    
    func weeksFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear!
    }
    
    func daysFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day!
    }
    
    func hoursFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour!
    }
    
    func minutesFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute!
    }
    
    func secondsFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second!
    }
    
    func offsetFrom(_ date: Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
    
    static func conversationMessageTimestampFromDate(_ date: Date)-> NSAttributedString {
        
        let formatter = DateFormatter()
        formatter.amSymbol = " am"
        formatter.pmSymbol = " pm"
        formatter.dateFormat = self.timeIs12HourFormat() ? "h:mma" : "H:MM"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM d"
        
        let day = date.weekday
        let monthDay = monthFormatter.string(from: date)
        let timeString = formatter.string(from: date)
        
        var resultTimestamp = day
        resultTimestamp = "\(resultTimestamp) \(monthDay) at \(timeString)"
        
        let attributedString = NSAttributedString(string: "\n\n\(resultTimestamp)\n\n", attributes: [NSFontAttributeName: UIFont.mallotyLight(10), NSForegroundColorAttributeName: UIColor.TMColorWithRGBFloat(170.0, green: 170.0, blue: 170.0, alpha: 1.0)])
        
        return attributedString
    }
    
    static func timeIs12HourFormat()-> Bool {
        
        let formatStringForHours = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: NSLocale.current)
        
        guard let _formatStringForHours = formatStringForHours else {
            return false
        }
        
        let isContainsA = _formatStringForHours.contains("a")
        return isContainsA
    }
}
