//
//  TMJSON.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/10/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import SwiftyJSON

extension JSON {
    
    public var nsString: NSString? {
        
        switch self.type {
        case .string: return NSString(string: object as! String)
        default: return nil
        }
    }
    
    public var price: NSNumber? {
        
        switch self.type {
        case .number:
            
            let floatObject = Float(object as! Int)
            let priceDivider = Float(100)
            
            return NSNumber(value: floatObject/priceDivider)
        default:
            return nil
        }
    }
    
    public var json: JSON? {
        
        switch self.type {
        case .dictionary: return JSON(object)
        default: return nil
        }
    }
    
    public var phone: String? {
        
        switch self.type {
        case .string:
            
            do {
                
                let phoneKit = PhoneNumberKit()
                
                let numberPhone = try phoneKit.parse(object as! String, withRegion: "US")
                
                let formatedPhone = phoneKit.format(numberPhone, toType: .national)
                
                return formatedPhone
            }
            catch {
                return nil
            }
        default:
            return nil
        }
    }
    
    public var date: Date? {
        
        switch self.type {
        case .string:
            return JSONFormatter.jsonDateFormatter.date(from: object as! String)
        default:
            return nil
        }
    }
    
    public var dateTime: Date? {
        
        switch self.type {
        case .string:
            return JSONFormatter.jsonDateTimeFormatter.date(from: object as! String)
        default:
            return nil
        }
    }
    
    public var boolNumber: NSNumber? {
        
        switch self.type {
        case .bool: return NSNumber(value: object as! Bool)
        default:
            return nil
        }
    }
}

class JSONFormatter {
    
    fileprivate static var internalJsonDateFormatter: DateFormatter?
    fileprivate static var internalJsonDateTimeFormatter: DateFormatter?
    
    static var jsonDateFormatter: DateFormatter {
        if (internalJsonDateFormatter == nil) {
            internalJsonDateFormatter = DateFormatter()
            internalJsonDateFormatter!.dateFormat = "yyyy-MM-dd"
        }
        return internalJsonDateFormatter!
    }
    
    static var jsonDateTimeFormatter: DateFormatter {
        if (internalJsonDateTimeFormatter == nil) {
            internalJsonDateTimeFormatter = DateFormatter()
            internalJsonDateTimeFormatter!.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        }
        return internalJsonDateTimeFormatter!
    }
}
