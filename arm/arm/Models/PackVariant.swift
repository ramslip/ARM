//
//  PackVariant.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 20.10.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class PackVariant: Object {
    dynamic var id = 0
    dynamic var date = Date()
    dynamic var packGroupId = 0
    dynamic var studentId = 0
    dynamic var variant = 0

    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: Int, date: String, packGroupId: Int, studentId: Int, variant: Int) {
        self.init()
        self.id = id
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        self.date = dateFormatter.date(from: date)!
        self.packGroupId = packGroupId
        self.studentId = studentId
        self.variant = variant
    }
}
