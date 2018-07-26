//
//  Work.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 19.10.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class Work: BaseObject {
    dynamic var name = ""
    dynamic var shortName = ""
    dynamic var workControlTypeId = 0
    dynamic var workTypeId = 0
    dynamic var courseId = 0
    dynamic var hasThemes = false
    
    convenience init(id: Int, name: String, shortName: String, workControlTypeId: Int, workTypeId: Int, courseId: Int, hasThemes: Bool) {
        self.init()
        self.id = id
        self.name = name
        self.shortName = shortName
        self.workControlTypeId = workControlTypeId
        self.workTypeId = workTypeId
        self.courseId = courseId
        self.hasThemes = hasThemes
    }
    
    class func serializeWorks(worksArray:[Dictionary<String, Any>]?) -> [Work] {
        var worksArrayToReturn = [Work]()
        for currentWork in worksArray! {
            let hasThemes = currentWork["hasThemes"] as! Bool
            
            let work = Work(id: currentWork["id"] as! Int, name: currentWork["name"] as! String, shortName: currentWork["shortName"] as! String, workControlTypeId: currentWork["workControlTypeId"] as! Int, workTypeId: currentWork["workTypeId"] as! Int, courseId: currentWork["courseId"] as! Int, hasThemes: hasThemes)
            worksArrayToReturn.append(work)
        }
        return worksArrayToReturn
    }
}
