//
//  Subject.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 18.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class Subject: BaseObject {
    
    dynamic var name = ""
    
    convenience init(id: Int, name:String) {
        self.init()
        self.id = id
        self.name = name
    }
    
    class func serializeSubjects(subjectsArray:[Dictionary<String, Any>]?) -> [Subject] {
        var subjectsArrayToReturn = [Subject]()
        for currentSubject in subjectsArray! {
            let subject = Subject(id: currentSubject["id"] as! Int, name: currentSubject["name"] as! String)
            subjectsArrayToReturn.append(subject)
        }
        return subjectsArrayToReturn
    }
}
