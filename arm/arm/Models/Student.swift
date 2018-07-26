//
//  Student.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 23.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class Student: BaseObject {
    dynamic var name = ""
    dynamic var surname = ""
    dynamic var patronymic = ""

    var group: Group?
    
    override static func ignoredProperties() -> [String] {
        return ["group"]
    }
    
    convenience init(id: Int, name:String, surname:String, patronymic: String) {
        self.init()
        self.id = id
        self.name = name
        self.surname = surname
        self.patronymic = patronymic
    }
    
    class func serializeStudents(studentsArray:[Dictionary<String, Any>]?) -> [Student] {
        var studentsArrayToReturn = [Student]()
        for currentStudent in studentsArray! {
            let student = Student(id: currentStudent["id"] as! Int, name: currentStudent["name"] as! String, surname: currentStudent["surname"] as! String, patronymic: (currentStudent["patronymic"] as? String) ?? "")
            studentsArrayToReturn.append(student)
        }
        return studentsArrayToReturn
    }
    
    func nameForPack() -> String {
        let index = self.name.index(self.name.startIndex, offsetBy: 1)
        return self.surname + " " + self.name.substring(to: index) + "."
    }
    
    var shortName: String {
        let index = self.name.index(self.name.startIndex, offsetBy: 1)
        var shortName = self.surname + " " + self.name.substring(to: index) + "."
        
        if self.patronymic.count > 0 {
            
            var patronymicCharacter: String
            
            let index = self.patronymic.index(self.patronymic.startIndex, offsetBy: 1)
            patronymicCharacter = self.patronymic.substring(to: index)
            patronymicCharacter += "."
            
            shortName += " "
            shortName += patronymicCharacter
        }
        
        return shortName
    }
}
