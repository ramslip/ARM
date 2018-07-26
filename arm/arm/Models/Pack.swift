//
//  Pack.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 21.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class Pack: BaseObject {
    dynamic var type = 0
    dynamic var courseId = 0

    var course: Course?
    var groups: [Group]? = []
    var lessons: [Lesson]? = []
    
    override static func ignoredProperties() -> [String] {
        return ["course", "groups", "lessons"]
    }
    
    convenience init(id: Int, type:Int, courseId:Int) {
        self.init()
        self.id = id
        self.type = type
        self.courseId = courseId
//        self.course = realmInstance.object(ofType: Course.self, forPrimaryKey: courseId)
    }
    
    class func serializePacks(packsArray:[Dictionary<String, Any>]?) -> [Pack] {
        var packsArrayToReturn = [Pack]()
        for currentPack in packsArray! {
            let pack = Pack(id: currentPack["id"] as! Int, type: currentPack["type"] as! Int, courseId: currentPack["courseId"] as! Int)
            packsArrayToReturn.append(pack)
        }
        return packsArrayToReturn
    }
    
    class func addGroups() {
        for packInGroup in BaseContext.sharedContext.packToGroups {
            let pack = BaseContext.sharedContext.packs.filter{ $0.id == packInGroup.packId }.first
            let group = BaseContext.sharedContext.groups.filter{ $0.id == packInGroup.groupId }.first
            pack?.groups?.append(group!)
        }
    }
    
    class func addLessons() {
        for lesson in BaseContext.sharedContext.lessons {
            let pack = BaseContext.sharedContext.packs.filter{ $0.id == lesson.packId }.first
            pack?.lessons?.append(lesson)
        }
    }
    
    func stringType() -> String {
        return self.type == 1 ? "Лекции" : "Лаб. Работы"
    }
    
    func groupsNames() -> String {
        var stringToReturn = ""
        for group in self.groups! {
            stringToReturn = stringToReturn + group.name + " "
        }
        return stringToReturn
    }
}
