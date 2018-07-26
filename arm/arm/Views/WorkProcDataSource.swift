//
//  WorkProcDataSource.swift
//  homework
//
//  Created by Victor Kalevko on 26.11.16.
//  Copyright © 2016 Victor Kalevko. All rights reserved.
//

import UIKit
import M13Checkbox

class WorkProcItem {
    
    let stageName : String
    let isSubstage: Bool
    var isDone: Bool
    let workStageId: Int
    let studentWorkProcId: Int
    let id: Int
    let workId: Int
    let studentId: Int
    
    init(stageName: String, isSubStage : Bool, isDone : Bool, workStageId : Int, studentWorkProcId : Int, id : Int, workId:Int, studentId:Int) {
        self.stageName = stageName
        self.isSubstage = isSubStage
        self.isDone = isDone
        self.workStageId = workStageId
        self.studentWorkProcId = studentWorkProcId
        self.id = id
        self.workId = workId
        self.studentId = studentId
    }
    
    func toggleDone() {
        isDone = !isDone
        let workProc = BaseContext.sharedContext.workProcs.filter({$0.workId == self.workId}).first
        let studentWorkProcs = workProc?.studentWorkProcs.filter({$0.studentId == self.studentId}).first
        let studentStageProc = studentWorkProcs?.studentStageProcs.filter({$0.id == self.id}).first

        try! realmInstance.write {
            studentStageProc?.completed = isDone
            if (isDone) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                studentStageProc?.completionDate = dateFormatter.string(from: Date())
            }
            else {
                studentStageProc?.completionDate = ""
            }
            studentStageProc?.changed = true
            // reload pack spreadsheet view
        }
    }
}

class WorkProcDataSource: NSObject, UITableViewDataSource {

    let workProcItems : Array<WorkProcItem>
    
    var itemsEnabled: Bool = true
    
    init(tableView: UITableView, workProcItems: Array<WorkProcItem>) {
        self.workProcItems = workProcItems;
        
        tableView.register(WorkStageProcTableViewCell.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workProcItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : WorkStageProcTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        
        let workProcItem = self.workProcItems[indexPath.row]
        
        cell.label.text = workProcItem.stageName
        cell.checkBox.checkState = workProcItem.isDone ? .checked : .unchecked
        cell.checkBoxLeftConstraint.constant = workProcItem.isSubstage ? 30 : 10
        cell.checkBox.stateChangeAnimation = .fill
        
        if itemsEnabled {
            cell.label.textColor = UIColor.darkText
            cell.checkBox.tintColor = ColorsHelper.blue()
            cell.selectionStyle = .default
            cell.checkBox.isEnabled = true
            cell.isUserInteractionEnabled = true
        }
        else {
            cell.label.textColor = UIColor.lightGray
            cell.checkBox.tintColor = ColorsHelper.blue().lighter()
            cell.selectionStyle = .none
            cell.checkBox.isEnabled = false
            cell.isUserInteractionEnabled = false
        }
        
        return cell;
    }

}
