//
//  Visit.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 29.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

enum VisitValue: Int {
    case none, half, full, important
    
    static var defaultValue: VisitValue{
        return .full
    }
}

class Visit: Object {
    
    @objc dynamic var studentId = 0
    @objc dynamic var changed = false
    @objc dynamic var value = 0
    @objc dynamic var version = 0
    
    var valueEnum: VisitValue{
        get {
            return VisitValue(rawValue: self.value)!
        }
        set{
            self.value = newValue.rawValue
        }
    }

    convenience init(studentId:Int, value: Int) {
        self.init()
        self.studentId = studentId
        self.value = value
    }

}
