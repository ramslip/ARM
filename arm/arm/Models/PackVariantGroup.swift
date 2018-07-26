//
//  PackVariantGroup.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 20.10.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class PackVariantGroup: Object {
    dynamic var id = 0
    dynamic var date = Date()
    dynamic var packId = 0
    dynamic var enabled = false

    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: Int, date: String, packId: Int, enabled: Bool) {
        self.init()
        self.id = id
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        self.date = dateFormatter.date(from: date)!
        self.packId = packId
        self.enabled = enabled
    }
}
