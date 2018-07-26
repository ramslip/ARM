//
//  WorkTheme.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 20.10.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class WorkTheme: Object {
    dynamic var name = ""
    dynamic var serverId = 0
    dynamic var localId = 0
    dynamic var workId = 0

    override static func primaryKey() -> String? {
        return "serverId"
    }
    
    convenience init(id: Int, name: String, serverId: Int, workId: Int) {
        self.init()
        self.localId = id
        self.name = name
        self.serverId = serverId
        self.workId = workId
    }
    
    convenience init(json: Dictionary<String, Any>) {
        self.init()
        self.localId = json["id"] as! Int
        self.serverId = json["serverId"] as! Int
        self.name = json["name"] as! String
        self.workId = json["workId"] as! Int
    }
}
