//
//  StudentWorkProc.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 20.10.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class StudentWorkProc: BaseObject {
    @objc dynamic var workThemeId = 0
    @objc dynamic var studentId = 0
    @objc dynamic var completionDate = ""
    @objc dynamic var state = 0
    @objc dynamic var localThemeId = 0
    @objc dynamic var version = 0
    @objc dynamic var changed = false
    @objc dynamic var completion = 0

    let studentStageProcs = List<StudentStageProc>()
    
    convenience init(id: Int, workThemeId: Int, studentId: Int, completionDate: String, version: Int, state: Int, localThemeId: Int, changed: Bool, completion: Int) {
        self.init()
        self.id = id
        self.version = version
        self.state = state
        self.changed = changed
        self.workThemeId = workThemeId
        self.studentId = studentId
        self.completion = completion
        self.completionDate =  completionDate
        self.localThemeId = localThemeId
    }
    
    func dictionary() -> Dictionary<String, Any> {
        var studentStageProcs = [[String : Any]]()
        for studentStageProc in self.studentStageProcs {
            studentStageProcs.append(studentStageProc.dictionary())
        }
        let studentWorkProc = ["completionDate" : self.completionDate,
                               "id" : self.id,
                               "completion" : self.completion,
                               "studentId" : self.studentId,
                               "version" : self.version,
                               "workThemeId" : self.workThemeId,
                               "studentWorkProcId" : self.id] as Dictionary<String, Any>
        return ["studentWorkProcId" : self.id,
                "studentStageProcs" : studentStageProcs,
                "studentWorkProc" : studentWorkProc]
    }
}
