//
//  NewLessonDateViewController.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 01.09.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import FSCalendar

class GroupSectionModel{
    let name: String
    let studentModels: [StudentVisitCellModel]
    
    init(name: String, studentModels: [StudentVisitCellModel]) {
        self.name = name
        self.studentModels = studentModels
    }
}

class StudentVisitCellModel {
    
    let studentIndex: Int
    let student: Student
    var visitValue: VisitValue
    let initalValue: VisitValue
    
    var hasChanged: Bool{
        return self.visitValue != self.initalValue
    }
    
    init(studentIndex: Int, student: Student, visitValue: VisitValue) {
        self.studentIndex = studentIndex
        self.student = student
        self.visitValue = visitValue
        self.initalValue = visitValue
    }
    
}

protocol NewLessonDateViewControllerDelegate {
    func lessonDidAdded(lesson: Lesson)
    func visitsDidUpdated(lesson: Lesson)
}

class NewLessonDateViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource, SyncStatusDelegate, NewLessonTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private weak var calendar: FSCalendar!
    private var isCalendar:Bool!
    
    var delegate: NewLessonDateViewControllerDelegate?
    
    var groups: [Group] = []
    var packId: Int = 0
    var lessonDate: Date!
    var isUpdatingVisits = false
    var lesson: Lesson!

    var sectionModels: [GroupSectionModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.setupSectionModels()
        
        if (self.isCalendar) {
            self.setupCalendar()
        }
        else {
            self.setupVisitsTable()
        }
        
        tableView.register(NewLessonTableViewCell.self)
        tableView.tableFooterView = UIView()
        
        self.title = self.isUpdatingVisits ? "Изменить посещаемость" : "Новое занятие"
        
        let doneButton = UIBarButtonItem(
            title: "Готово",
            style: .plain,
            target: self,
            action: #selector(done)
        )
        
        let cancelButton = UIBarButtonItem(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(cancel)
        )
        
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupSectionModels() {
        
        self.sectionModels = []
        
        for group in self.groups {
            var studentModels = [StudentVisitCellModel]()
            var index = 1
            
            for student in group.students! {
                
                var visitValue = VisitValue.defaultValue
                
                if self.isUpdatingVisits {
                    visitValue = self.lesson.visits.filter{$0.studentId == student.id}.first!.valueEnum
                }
                
                studentModels.append(StudentVisitCellModel(studentIndex: index, student: student, visitValue: visitValue))
                index += 1
            }
            
            self.sectionModels.append(GroupSectionModel(name: group.name, studentModels: studentModels))
        }
    }
    
    func updateVisits(lesson: Lesson, groups: [Group]) {
        self.isCalendar = false
        self.lesson = lesson
        self.groups = groups
        self.isUpdatingVisits = true
    }
    
    func setupVisitsTable() {
        if self.calendar != nil {
            self.calendar.isHidden = true
        }
        self.tableView.isHidden = false
        self.tableView.reloadData()
    }
    
    func setupCalendar() {
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: 300))
        calendar.firstWeekday = 2
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        self.calendar = calendar
    }
    
    func updateWithCalendar(isCalendar: Bool) {
        self.isCalendar = isCalendar
    }
    
    func done(){
        if self.isCalendar {
            self.isCalendar = false
            self.lessonDate = self.calendar.selectedDate == nil ? self.calendar.today : self.calendar.selectedDate/*.addingTimeInterval(86400)*/
            self.setupVisitsTable()
        }
        else {
            if self.isUpdatingVisits {
                NSLog("UPDATED")
                
                var changedVisits = [Visit]()
                
                for section in self.sectionModels {
                    changedVisits += section.studentModels
                        .filter({$0.hasChanged})
                        .map({Visit(studentId: $0.student.id, value: $0.visitValue.rawValue)})
                }
                
                RealmClient.sharedClient.updateVisits(visits: changedVisits, lesson: self.lesson)
                
                self.dismiss(animated: true, completion: {
                    self.delegate?.visitsDidUpdated(lesson: self.lesson)
                })
            }
            else {
                var visits = [Visit]()
                
                for section in self.sectionModels {
                    visits += section.studentModels
                        .map({Visit(studentId: $0.student.id, value: $0.visitValue.rawValue)})
                }
                
                let newLesson = RealmClient.sharedClient.createLesson(lessonDate: self.lessonDate, packId: self.packId, visits: visits)
                self.dismiss(animated: true, completion: {
                    self.delegate?.lessonDidAdded(lesson: newLesson)
                })
            }
        }
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionModels[section].studentModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:NewLessonTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.selectionStyle = .none
        
        let cellModel = self.sectionModels[indexPath.section].studentModels[indexPath.row]
        self.configure(cell: cell, model: cellModel)
        return cell
    }
    
    
    func configure(cell : NewLessonTableViewCell, model: StudentVisitCellModel){
        
        cell.numberLabel.text = "\(model.studentIndex)."
        cell.studentNameLabel.text = "\(model.student.surname) \(model.student.name)"
        cell.studentId = model.student.id
        cell.segmentControl.selectedSegmentIndex = model.visitValue.selectedSegmentIndex
        cell.delegate = self
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let groupName = self.sectionModels[section].name
        let label = CoursesTableViewHeaderLabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.text = groupName
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()
        label.backgroundColor = ColorsHelper.lightBlue()
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func visitValueChanged(newValue: VisitValue, studentId: Int) {

        for groupModel in self.sectionModels {
            for studentModel in groupModel.studentModels {
                
                if studentModel.student.id == studentId {
                    studentModel.visitValue = newValue
                }
            }
        }
        
    }
}
