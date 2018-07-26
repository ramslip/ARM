//
//  WorkProcsApiClientResponses.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 30.10.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

class WorkProcVersionInfo {
    
    let id: Int
    let version: Int
    let state: Int
    let scheme: Int
    let startDate: Date?
    let endDate: String?
    
    init(json: [String: Any]) {
        self.id = json["id"] as! Int
        self.version = json["version"] as! Int
        self.state = json["state"] as! Int
        self.scheme = json["scheme"] as! Int
        self.endDate = json["endDate"] as? String
        
        if let startDate = json["startDate"] as? String {
            self.startDate = Utils.dateWith(string: startDate)
        }
        else {
            self.startDate = nil
        }
    }
}

struct WorkProcModel {
    let workId: Int
    let id: Int
    let startDate: Date?
    let endDate: String?
    let state: Int
    let version: Int
    let scheme: Int
    let studentWorkProcs: [StudentWorkProcModel]
}

extension WorkProcModel {
    
    init(json: [String: Any]){
        self.workId = json["workId"] as! Int
        self.id = json["id"] as! Int
        self.state = json["state"] as! Int
        self.version = json["version"] as! Int
        self.scheme = json["scheme"] as! Int
        self.endDate = json["endDate"] as? String
        
        if let startDate = json["startDate"] as? String {
            self.startDate = Utils.dateWith(string: startDate)!
        }
        else {
            self.startDate = nil
        }
        
        let studentWorkProcsJsonArray = json["studentWorkProcs"] as! [Dictionary<String, Any>]
        self.studentWorkProcs = studentWorkProcsJsonArray.map{StudentWorkProcModel(json: $0) }
    }
}

struct StudentWorkProcModel {
    let studentId: Int?
    let version: Int
    let studentStageProcs: [StudentStageProcModel]
    let id: Int
    let completion: Int?
    let completionDate: String?
    let workThemeId: Int?
}

extension StudentWorkProcModel {

    init(json: [String: Any]){
        self.id = json["id"] as! Int
        self.studentId = json["studentId"] as? Int
        self.version = json["version"] as! Int
        self.completion = json["completion"] as? Int
        self.workThemeId = json["workThemeId"] as? Int
        self.completionDate = json["completionDate"] as? String
        if let studentStageProcsJsonArray = json["stageProcs"] as? [Dictionary<String, Any>] {
            self.studentStageProcs = studentStageProcsJsonArray.map{StudentStageProcModel(json: $0) }
        }
        else {
            self.studentStageProcs = []
        }
    }
}

struct StudentStageProcModel {
    let stageId: Int
    let version: Int
    let id: Int
    let completed: Bool
    let completionDate: String?
    let studentWorkProcId: Int = 0
}

extension StudentStageProcModel {
    init(json: [String: Any]){
        self.stageId = json["stageId"] as! Int
        self.version = json["version"] as! Int
        self.id = json["id"] as! Int
        self.completed = json["completed"] as! Bool
        self.completionDate = json["completionDate"] as? String
    }
    
    init(updateJSON: (key: String, value: Any)) {
        self.id = Int(updateJSON.key)!
        self.version = updateJSON.value as! Int
        self.stageId = 0
        self.completed = false
        self.completionDate = ""
    }
}

struct StudentProcUpdateResponse {
    let newVersion: Int
    let stageVersions: [Int:Int]
}

extension StudentProcUpdateResponse {
    
    init(updateJson: [String: Any]) {
        self.newVersion = updateJson["newVersion"] as! Int;
        let stageVersionsDictionary = updateJson["stageVersions"] as! [String : Int]

        var versions = [Int:Int]()
        for pair in stageVersionsDictionary {
            versions[Int(pair.key)!] = pair.value
        }
        self.stageVersions = versions
    }
    
}
