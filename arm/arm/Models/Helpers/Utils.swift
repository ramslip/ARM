//
//  DateFormatter.swift
//  arm
//
//  Created by Victor Kalevko on 21.10.2017.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

class Utils{
    
    class var dateFormatDefault: String{
        return "yyyy-MM-dd'T'HH:mm:ss"
    }
    
    class var lastSyncDateFormat: String{
        return "yyyy-MM-dd HH:mm:ss"
    }
    
    class var dateFormatterDayMonthYear: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }
    
    class var dateFormatWithSeconds: String{
        return "yyyy-MM-dd'T'HH:mm:ss.SSS"
    }
    
    class func dateWith(string: String) -> Date? {
        
        if string.count == 0 {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.dateFormatDefault
        
        let lessonDate = dateFormatter.date(from: string)
        
        if lessonDate != nil {
            return lessonDate
        }
        else{
            dateFormatter.dateFormat = self.dateFormatWithSeconds
            let date = dateFormatter.date(from: string)
            return date
        }
        
    }
    
    class func string(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.dateFormatDefault
        return dateFormatter.string(from: date)
    }
    
    class func lastSyncDateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.lastSyncDateFormat
        return dateFormatter.string(from: date)
    }
    
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
}

class CustomDateFormatter: DateFormatter {
    override init() {
        super.init()
        self.dateFormat = "dd.MM"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dateFormat = "dd.MM"
    }
}
