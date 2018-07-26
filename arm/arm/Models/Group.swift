//
//  Group.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 21.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class Group: BaseObject {
    dynamic var name = ""
    
    var packs: [Pack]?
    var students: [Student]?
    
    override static func ignoredProperties() -> [String] {
        return ["packs", "students"]
    }
    
    convenience init(id: Int, name:String) {
        self.init()
        self.id = id
        self.name = name
        self.students = []
        self.packs = []
    }
    
    class func serializeGroups(groupsArray:[Dictionary<String, Any>]?) -> [Group] {
        var groupsArrayToReturn = [Group]()
        for currentGroup in groupsArray! {
            let group = Group(id: currentGroup["id"] as! Int, name: currentGroup["name"] as! String)
            groupsArrayToReturn.append(group)
        }
        return groupsArrayToReturn
    }
}
