//
//  PackToGroups.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 21.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class PackToGroups: Object {
    dynamic var groupId = 0
    dynamic var packId = 0
    
    convenience init(groupId: Int, packId: Int) {
        self.init()
        self.groupId = groupId
        self.packId = packId
    }
    
    class func serializePackToGroups(packToGroupsArray:[Dictionary<String, Any>]?) -> [PackToGroups] {
        var packToGroupsArrayToReturn = [PackToGroups]()
        for currentPackToGroup in packToGroupsArray! {
            let packToGroup = PackToGroups(groupId: currentPackToGroup["groupId"] as! Int, packId: currentPackToGroup["packId"] as! Int)
            packToGroupsArrayToReturn.append(packToGroup)
        }
        return packToGroupsArrayToReturn
    }
}
