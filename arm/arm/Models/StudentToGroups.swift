//
//  StudentToGroups.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 23.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class StudentToGroups: Object {
    dynamic var groupId = 0
    dynamic var studentId = 0
    
    convenience init(groupId: Int, studentId: Int) {
        self.init()
        self.groupId = groupId
        self.studentId = studentId
    }
    
    class func serializeStudentToGroups(studentToGroupsArray:[Dictionary<String, Any>]?) -> [StudentToGroups] {
        var studentToGroupsArrayToReturn = [StudentToGroups]()
        for currentStudentToGroup in studentToGroupsArray! {
            let studentToGroup = StudentToGroups(groupId: currentStudentToGroup["groupId"] as! Int, studentId: currentStudentToGroup["studentId"] as! Int)
            studentToGroupsArrayToReturn.append(studentToGroup)
        }
        return studentToGroupsArrayToReturn
    }

}
