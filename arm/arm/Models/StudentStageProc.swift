//
//  StudentStageProc.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 20.10.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class StudentStageProc: BaseObject {
    @objc dynamic var workStageId = 0
    @objc dynamic var studentWorkProcId = 0
    @objc dynamic var completionDate = ""
    @objc dynamic var state = 0
    @objc dynamic var changed = false
    @objc dynamic var version = 0
    @objc dynamic var completed = false
    
    convenience init(id: Int, workStageId: Int, completionDate: String, state: Int, changed: Bool, version: Int, completed: Bool) {
        self.init()
        self.id = id
        self.workStageId = workStageId
        self.completionDate = completionDate
        self.state = state
        self.changed = changed
        self.version = version
        self.completed = completed
    }
    
    func dictionary() -> Dictionary<String, Any> {
        return ["completionDate" : self.completionDate,
                "completed" : self.completed,
                "id" : self.id,
                "stageId" : self.workStageId,
                "version" : self.version]
    }
}
