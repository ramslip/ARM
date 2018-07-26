//
//  Course.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 21.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class Course: BaseObject {
    dynamic var year = 0
    dynamic var termId = 0
    
    var term: Term?
    var packs: [Pack]?
    
    override static func ignoredProperties() -> [String] {
        return ["term", "packs"]
    }
    
    convenience init(id: Int, year:Int, termId:Int) {
        self.init()
        self.id = id
        self.year = year
        self.termId = termId
//        self.term = realmInstance.object(ofType: Term.self, forPrimaryKey: termId)
    }
    
    class func serializeCourses(coursesArray:[Dictionary<String, Any>]?) -> [Course] {
        var coursesArrayToReturn = [Course]()
        for currentCourse in coursesArray! {
            let course = Course(id: currentCourse["id"] as! Int, year: currentCourse["year"] as! Int, termId: currentCourse["termId"] as! Int)
            coursesArrayToReturn.append(course)
        }
        return coursesArrayToReturn
    }
    
    func courseNameForYear() -> String {
        let beginYearInt = self.year % 100
        let beginYearString = String(beginYearInt) + " - "
        let endYearInt = beginYearInt + 1
        let endYearString = String(endYearInt) + " уч. гг."

        return beginYearString + endYearString
    }
}
