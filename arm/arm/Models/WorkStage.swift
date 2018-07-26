//
//  WorkStage.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 20.10.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class WorkStage: BaseObject {
    dynamic var workId = 0
    dynamic var parentWorkStageId = 0
    dynamic var optional = 0
    dynamic var name = ""
    
    convenience init(id: Int, workId: Int, parentWorkStageId: Int, optional: Int, name: String) {
        self.init()
        self.id = id
        self.workId = workId
        self.parentWorkStageId = parentWorkStageId
        self.optional = optional
        self.name = name
    }
    
    class func serializeWorkStages(workStagesArray:[Dictionary<String, Any>]?) -> [WorkStage] {
        var workStagesArrayToReturn = [WorkStage]()
        for currentWorkStage in workStagesArray! {
            let workStage = WorkStage(id: currentWorkStage["id"] as! Int, workId: currentWorkStage["workId"] as! Int, parentWorkStageId: currentWorkStage["parentWorkStageId"] as? Int ?? 0, optional: currentWorkStage["optional"] as! Int, name: currentWorkStage["name"] as! String)
            workStagesArrayToReturn.append(workStage)
        }
        return workStagesArrayToReturn
    }
}
