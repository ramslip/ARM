//
//  LessonApiClientResponses.swift
//  arm
//
//  Created by Victor Kalevko on 21.10.2017.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

class LessonDateInfo {
    
    let serverLessonId: Int
    let version: Int
    let lessonDate: Date
    
    init(json: [String: Any]) {
        self.serverLessonId = json["serverId"] as! Int
        self.version = json["version"] as! Int
        let date = json["lessonDate"] as! String
        self.lessonDate = Utils.dateWith(string: date)!
    }
}

struct LessonModel {
    let serverId: Int
    let packId: Int
    let version: Int
    let lessonDate: Date
    let visits: [VisitModel]    
}

extension LessonModel{
    
    init(json: [String: Any]){
        self.serverId = json["serverId"] as! Int
        self.packId = json["packId"] as! Int
        self.version = json["version"] as! Int
        let date = json["lessonDate"] as! String
        self.lessonDate = Utils.dateWith(string: date)!
        
        let visitsJsonArray = json["visits"] as! [Dictionary<String, Any>]
        self.visits = visitsJsonArray.map{VisitModel(json: $0) }
    }
    
    func dictionary() -> Dictionary<String, Any> {
        let visits = self.visits.map({$0.dictionary()})
        
        return ["serverId" : self.serverId,
                "packId" : self.packId,
                "version" : self.version,
                "lessonDate" : Utils.string(from: self.lessonDate),
                "visits" : visits]
    }
}

struct VisitModel {
    let studentId: Int
    let value: Int
    let version: Int
}

extension VisitModel{
    
    init(json: [String: Any]){
        self.studentId = json["studentId"] as! Int
        self.value = json["value"] as! Int
        self.version = json["version"] as! Int
    }
    
    func dictionary() -> Dictionary<String, Any> {
        return ["studentId" : self.studentId,
                "value" : self.value,
                "version" : self.version]
    }
}

struct UpdateLessonResponseData {
    let newVersion: Int
    let visits: [VisitModel]
}

extension UpdateLessonResponseData{
    
    init(json: [String: Any]) {
        self.newVersion = json["newVersion"] as! Int
        let visitsJsonArray = json["visitDataList"] as! [Dictionary<String, Any>]
        self.visits = visitsJsonArray.map{VisitModel(json: $0) }
    }
}
