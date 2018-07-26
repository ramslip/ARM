//
//  Term.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 18.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class Term: BaseObject {
    
    dynamic var name = ""
    dynamic var subjectId = 0
    
    var subject: Subject?
    
    override static func ignoredProperties() -> [String] {
        return ["subject"]
    }
    
    convenience init(id: Int, name:String, subjectId:Int) {
        self.init()
        self.id = id
        self.name = name
        self.subjectId = subjectId
//        self.subject = realmInstance.object(ofType: Subject.self, forPrimaryKey: subjectId)
    }

    class func serializeTerms(termsArray:[Dictionary<String, Any>]?) -> [Term] {
        var termsArrayToReturn = [Term]()
        for currentTerm in termsArray! {
            let term = Term(id: currentTerm["id"] as! Int, name: currentTerm["name"] as! String, subjectId: currentTerm["subjectId"] as! Int)
            termsArrayToReturn.append(term)
        }
        return termsArrayToReturn
    }
}
