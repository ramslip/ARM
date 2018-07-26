//
//  WorkProc.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 20.10.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class WorkProc: Object {
    
    @objc dynamic var serverId = 0
    @objc dynamic var workId = 0
    @objc dynamic var packId = 0
    @objc dynamic var startDate: Date?
    @objc dynamic var endDate: Date?
    @objc dynamic var version = 0
    @objc dynamic var state = 0
    @objc dynamic var scheme = 0
    @objc dynamic var changed = false
    
    let studentWorkProcs = List<StudentWorkProc>()
    
    func dictionary() -> Dictionary<String, Any> {
        var endDateString = ""
        if (self.endDate != nil) {
            endDateString = Utils.string(from: self.endDate!)
        }
        return ["endDate" : endDateString,
                "startDate" : Utils.string(from: self.startDate!),
                "scheme" : self.scheme,
                "state" : self.state,
                "version" : self.version,
                "workId" : self.workId,
                "id" : self.serverId]
    }

}
