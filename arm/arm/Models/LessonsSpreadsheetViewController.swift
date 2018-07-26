//
//  PackSpreadsheetDataSource.swift
//  arm
//
//  Created by Victor Kalevko on 02.01.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import SpreadsheetView

class LessonSpreadsheetColumnModel : SpreadsheetColumnModel {
    
    private static let dateFormatter = CustomDateFormatter()
    
    let date: Date
    let studentIds: [Int]
    let studentVisits: [Int: VisitValue]
    
    init(date: Date, studentIds: [Int], visits: [Visit]) {
        self.date = date
        self.studentIds = studentIds
        self.studentVisits = visits.dictionary(transform: {[$0.studentId : $0.valueEnum]})
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
        return 65
    }
    
    func cellForHeader(spreadsheetView: SpreadsheetView) -> Cell {
        let cell: PackCollectionViewCell = spreadsheetView.dequeueReusableCell()
        cell.configGridlines(with: .blue)
        cell.textLabel.text = LessonSpreadsheetColumnModel.dateFormatter.string(from: self.date)
        cell.textLabel.textAlignment = .center
        return cell
    }
    
    func cellFor(row: Int, spreadsheetView: SpreadsheetView) -> Cell {
        let cell: PackCollectionViewCell = spreadsheetView.dequeueReusableCell()
        cell.configGridlines()
        cell.textLabel.textAlignment = .center
        
        if let visitForStudent = self.studentVisits[self.studentIds[row]] {
            cell.textLabel.text = visitForStudent.title
            cell.backgroundColor = visitForStudent.tintColor
        }
        else {
            cell.textLabel.text = "???"
        }
        return cell
    }
}

protocol LessonsSpreadsheetViewControllerDelegate {
    func didSelect(lesson: Lesson)
}

class LessonsSpreadsheetViewController: NSObject, SpreadsheetViewController {
    
    private var lessons: [Lesson]
    private let defaultEmptyColumns: Int
    private let studentsCount: Int
    private let studentIds: [Int]
    
    private var columns: [SpreadsheetColumnModel] {
        var result = [SpreadsheetColumnModel]()
        result.append(contentsOf: defaultColumns)
        result.append(contentsOf: lessonsColumns as [SpreadsheetColumnModel])
        result.append(contentsOf: emptyColumns)
        return result
    }
    
    private var defaultColumns: [SpreadsheetColumnModel]
    private var lessonsColumns: [LessonSpreadsheetColumnModel]
    private var emptyColumns: [SpreadsheetColumnModel] = []
    
    var delegate: LessonsSpreadsheetViewControllerDelegate?
    
    init(students: [Student], lessons: [Lesson], defaultEmptyColumns: Int = 5){
        self.lessons = lessons
        self.defaultEmptyColumns = defaultEmptyColumns
        self.studentsCount = students.count
        
        let indexTitles = (1...students.count).map({ "\($0)" })
        
        self.defaultColumns = []
        self.defaultColumns.append(SimpleSpreadsheetColumnModel(headerTitle: "#", rowTitles: indexTitles, textAlignment: .center))
        self.defaultColumns.append(SimpleSpreadsheetColumnModel(headerTitle: "Студент", rowTitles: students.map({$0.shortName})))
        
        self.studentIds = students.map({$0.id})
        
        self.lessonsColumns = []
        
        for lesson in lessons {
            self.lessonsColumns.append(LessonSpreadsheetColumnModel(date: lesson.date, studentIds: studentIds, visits: Array(lesson.visits)))
        }
        
        super.init()
        
        setupEmptyColumns()
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
        let lessonIndex = column - 2
        
        guard row == 0, lessonIndex >= 0, lessonIndex < self.lessons.count else {
            return
        }
        
        self.delegate?.didSelect(lesson: self.lessons[lessonIndex])
    }
    
    func updateLesson(lesson: Lesson){
        guard let lessonIndex = self.lessons.index(where: {$0.date == lesson.date}) else {
            return
        }
        
        let updatedColumnModel = LessonSpreadsheetColumnModel(date: lesson.date, studentIds: self.studentIds, visits: Array(lesson.visits))
        
        self.lessonsColumns[lessonIndex] = updatedColumnModel
    }
    
    func addLesson(lesson: Lesson){
        let addedColumnModel = LessonSpreadsheetColumnModel(date: lesson.date, studentIds: self.studentIds, visits: Array(lesson.visits))
        
        self.lessonsColumns.append(addedColumnModel)
        self.lessonsColumns.sort(by: {$0.0.date < $0.1.date})
        
        self.lessons.append(lesson)
        self.lessons.sort(by: {$0.0.date < $0.1.date})
        
        setupEmptyColumns()
    }
    
    func removeLesson(lesson: Lesson){
        self.lessons = self.lessons.filter({$0 != lesson})
        self.lessonsColumns = self.lessonsColumns.filter({$0.date != lesson.date})
        
        setupEmptyColumns()
    }
}

