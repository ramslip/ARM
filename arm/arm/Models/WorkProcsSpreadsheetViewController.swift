//
//  PackLabsSpreadsheetViewController.swift
//  arm
//
//  Created by Victor Kalevko on 04.01.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import SpreadsheetView

class WorkProcColumnModel : SpreadsheetColumnModel {
    
    struct StudentWorkProgress {
        let studentId: Int
        var progress: Float = 0
        var title: String = ""
    }
    
    let studentIds: [Int]
    let shortName: String
    var studentProgress: [Int: StudentWorkProgress]
    
    let endDate: Date?
    
    private static let dateFormatter = CustomDateFormatter()
    
    init(work: Work, workProc: WorkProc, studentIds: [Int]) {
        self.studentIds = studentIds
        self.shortName = work.shortName
        self.endDate = workProc.endDate
        self.studentProgress = [:]
        
        for studentId in studentIds {
            
            if let studentProc = workProc.studentWorkProcs.first(where: {$0.studentId == studentId}) {
                
                var studentWorkProgress = StudentWorkProgress(studentId: studentId, progress: 0, title: "")
                
                if studentProc.completion > 0 {
                    studentWorkProgress.progress = 1.0
                    
                    if work.workControlTypeId == 1 {
                        studentWorkProgress.title = "+"
                    }
                    else {
                        studentWorkProgress.title = "\(studentProc.completion)"
                    }
                }
                else {
                    let completedStagesCount = studentProc.studentStageProcs.filter { (studentStageProc : StudentStageProc) -> Bool in
                        return studentStageProc.completed
                        }.count
                    
                    let studentProgress = studentProc.studentStageProcs.count > 0 ? Float(completedStagesCount) / Float(studentProc.studentStageProcs.count) : 0
                    
                    studentWorkProgress.progress = studentProgress
                    studentWorkProgress.title = studentProgress > 0.0 ? "\(Int(studentProgress * 100))%" : ""
                }
                studentProgress[studentId] = studentWorkProgress
            }
        }
    }
    
    var numberOfRows: Int {
        return studentIds.count
    }
    
    func heightForHeader() -> CGFloat {
        return 50
    }
    
    func heightFor(row: Int) -> CGFloat {
        return 50
    }
    
    func widthForColumn() -> CGFloat {
        return 90
    }
    
    func cellForHeader(spreadsheetView: SpreadsheetView) -> Cell {
        
        if let endDate = self.endDate {
            let cell: HeaderWithSubtitleCell = spreadsheetView.dequeueReusableCell()
            cell.configGridlines(with: .blue)
            cell.textLabel.text = self.shortName
            cell.textLabel.textAlignment = .center
            cell.subtitleLabel.text = WorkProcColumnModel.dateFormatter.string(from: endDate)
            return cell
        }
        else {
            let cell: PackCollectionViewCell = spreadsheetView.dequeueReusableCell()
            cell.configGridlines(with: .blue)
            cell.textLabel.text = self.shortName
            cell.textLabel.textAlignment = .center
            return cell
        }
    }
    
    func cellFor(row: Int, spreadsheetView: SpreadsheetView) -> Cell {
        let cell: PackWorkProgressViewCell = spreadsheetView.dequeueReusableCell()
        cell.configGridlines(with: .blue)
        
        if let studentProgress = studentProgress[studentIds[row]] {
            cell.progress = studentProgress.progress
            cell.textLabel.text = studentProgress.title
        }
        else {
            //TODO:
        }
        
        return cell
    }
}

class WorkProcWithThemesColumnModel : WorkProcColumnModel {
 
    override func widthForColumn() -> CGFloat {
        return 140
    }
    
    override func cellFor(row: Int, spreadsheetView: SpreadsheetView) -> Cell {
        let cell: PackWorkWithThemeProgressViewCell = spreadsheetView.dequeueReusableCell()
        cell.configGridlines(with: .blue)
        
        if let studentProgress = studentProgress[studentIds[row]] {
            cell.progress = studentProgress.progress
            cell.textLabel.text = studentProgress.title
            
            let studentWorkProc = realmInstance.objects(StudentWorkProc.self).first(where: {$0.studentId == studentProgress.studentId})
            let theme = realmInstance.objects(WorkTheme.self).first(where: {$0.serverId == studentWorkProc?.workThemeId})
            cell.themeLabel.numberOfLines = 0
            cell.themeLabel.text = theme?.name != nil ? theme?.name : "Тема не выбрана"
        }
        else {
            //TODO:
        }
        
        return cell
    }
}

protocol WorkProcsSpreadsheetViewControllerDelegate {
    func didSelect(workProc: WorkProc)
    
    func didSelect(studentProc: StudentWorkProc, workProc: WorkProc)
}

class WorkProcsSpreadsheetViewController: NSObject, SpreadsheetViewController {
    
    private let defaultEmptyColumns: Int
    private let studentsCount: Int
    private var workProcs: [WorkProc]
    private let works: [Work]
    private let studentIds: [Int]
    
    private var defaultColumns: [SpreadsheetColumnModel]
    private var workProcsColumns: [WorkProcColumnModel]
    private var emptyColumns: [SpreadsheetColumnModel] = []
    
    private var columns: [SpreadsheetColumnModel] {
        var result = [SpreadsheetColumnModel]()
        result.append(contentsOf: defaultColumns)
        result.append(contentsOf: workProcsColumns as [SpreadsheetColumnModel])
        result.append(contentsOf: emptyColumns)
        return result
    }
    
    
    var delegate: WorkProcsSpreadsheetViewControllerDelegate?
    
    init(students: [Student], workProcs: [WorkProc], works: [Work], defaultEmptyColumns: Int = 5){
        self.studentsCount = students.count
        self.works = works
        self.defaultEmptyColumns = defaultEmptyColumns
        self.workProcs = workProcs
        
        self.defaultColumns = []
        let indexTitles = (1...students.count).map({ "\($0)" })
    
        self.defaultColumns.append(SimpleSpreadsheetColumnModel(headerTitle: "#", rowTitles: indexTitles, textAlignment: .center))
        self.defaultColumns.append(SimpleSpreadsheetColumnModel(headerTitle: "Студент", rowTitles: students.map({$0.shortName})))
        
        self.studentIds = students.map({$0.id})
        
        self.workProcsColumns = []
        
        super.init()
        
        for workProc in workProcs {
            appendWorkProcColumn(workProc: workProc)
        }
        
        setupEmptyColumns()
    }
    
    func updateWork(work: Work, workProc: WorkProc) {
        guard let workIndex = self.workProcs.index(where: {$0.serverId == workProc.serverId}) else {
            return
        }
        if work.hasThemes {
            let updatedColumnModel = WorkProcWithThemesColumnModel(work: work, workProc: workProc, studentIds: self.studentIds)
            self.workProcsColumns[workIndex] = updatedColumnModel;
        }
        else {
            let updatedColumnModel = WorkProcColumnModel(work: work, workProc: workProc, studentIds: self.studentIds)
            self.workProcsColumns[workIndex] = updatedColumnModel;
        }
    }
    
    private func setupEmptyColumns() {
        self.emptyColumns = []
        var currentColumnsCount = self.columns.count
        
        while currentColumnsCount < defaultEmptyColumns + self.defaultColumns.count {
            self.emptyColumns.append(EmptyColumnModel(rowsCount: studentsCount))
            currentColumnsCount += 1
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return self.columns[column].widthForColumn()
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        //        return 40 //TODO
        return 50
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return self.columns.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return self.studentsCount + 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let row = indexPath.row
        let column = indexPath.section
        let columnModel = self.columns[column]
        
        if row == 0 {
            return columnModel.cellForHeader(spreadsheetView: spreadsheetView)
        }
        
        return columnModel.cellFor(row: row - 1, spreadsheetView: spreadsheetView)
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        return []
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 2
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        let column = indexPath.section
        let row = indexPath.row
        let workProcIndex = column - 2
        
        guard workProcIndex >= 0, workProcIndex < self.workProcs.count else {
            return
        }
        
        let workProc = self.workProcs[workProcIndex]
        
        if row == 0 {
            self.delegate?.didSelect(workProc: workProc)
        }
        else {
            let studentId = self.studentIds[row - 1]
            if let studentProc = workProc.studentWorkProcs.first(where: {$0.studentId == studentId}) {
                self.delegate?.didSelect(studentProc: studentProc, workProc: workProc)
            }
        }
    }
    
    private func appendWorkProcColumn(workProc: WorkProc) {
        let work = works.first(where: {$0.id == workProc.workId})!
        
        if work.hasThemes {
            self.workProcsColumns.append(WorkProcWithThemesColumnModel(work: work, workProc: workProc, studentIds: studentIds))
        }
        else {
            self.workProcsColumns.append(WorkProcColumnModel(work: work, workProc: workProc, studentIds: studentIds))
        }
    }
    
    func add(workProc: WorkProc) {
        
        if workProcs.first(where: {$0.serverId == workProc.serverId}) != nil {
            return
        }

        self.workProcs.append(workProc)
        appendWorkProcColumn(workProc: workProc)
        
        setupEmptyColumns()
    }
}

