//
//  AvailableCoursesViewController.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 21.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift


class CourseGroupView: UIView {
    
    private let titleLabel = UILabel()
    
    private let kMarginDefault: CGFloat = 10
    
    private let topSeparator = UIView()
    private let bottomSeparator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(titleLabel)
        self.addSubview(topSeparator)
        self.addSubview(bottomSeparator)
        
        bottomSeparator.backgroundColor = .separator
        topSeparator.backgroundColor = .separator
        
        titleLabel.textColor = UIColor.darkGray
        titleLabel.numberOfLines = 0
        
        self.backgroundColor = UIColor.lightGray
    }
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
            titleLabel.sizeToFit()
            setNeedsLayout()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.topSeparator.pin.topLeft().right().height(0.5)
        self.bottomSeparator.pin.bottomLeft().right().height(0.5)
        
        let maxWidth = self.frame.size.width - kMarginDefault * 2
        
        let titleLabelHeight = self.titleLabel.findHeight(widthValue: maxWidth)
        
        self.titleLabel.pin.topLeft().right()
            .height(titleLabelHeight)
            .margin(kMarginDefault)
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var totalHeight: CGFloat = 0
        let maxWidth = size.width - kMarginDefault * 2
        let titleLabelHeight = self.titleLabel.findHeight(widthValue: maxWidth)
        
        totalHeight = titleLabelHeight + kMarginDefault * 2
        
        return CGSize(width: size.width, height: totalHeight)
    }
}


class AvailableCoursesViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedLabelText: String?
    var selectedSectionText: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "АРМ Преподавателя"
        tableView.register(UINib(nibName: "CoursesTableViewCell", bundle: nil), forCellReuseIdentifier: "CoursesTableViewCell")
        tableView.tableFooterView = UIView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(cancelPressed))
    }
    
    func cancelPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return BaseContext.sharedContext.packsInCourses.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let packsInCourses = BaseContext.sharedContext.packsInCourses
//        print("packsInCourses: \(packsInCourses)")
        let course = packsInCourses[section]
        return (course.packs?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoursesTableViewCell", for: indexPath) as! CoursesTableViewCell
        let course = BaseContext.sharedContext.packsInCourses[indexPath.section]
        let pack = course.packs?[indexPath.row]
        cell.update(groupName: (pack?.groupsNames())!, packType: (pack?.stringType())!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let view = CourseGroupView(frame: .zero)
        view.title = self.formHeaderTitle(indexPath: IndexPath(item: 0, section: section))
        
        return view.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width, height: .greatestFiniteMagnitude)).height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = self.formHeaderTitle(indexPath: IndexPath(item: 0, section: section))

        let headerView = CourseGroupView(frame: .zero)
        headerView.title = title
        headerView.backgroundColor = ColorsHelper.lightBlue()
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedSectionText = self.formSubjectHeaderTitle(indexPath: indexPath)
        self.selectedLabelText = self.formCellTitle(indexPath: indexPath)
        _ = [self .performSegue(withIdentifier: "showGroup", sender: self)]
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGroup" {
            let viewController:PackViewController = segue.destination as! PackViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            
//            let temppacks = BaseContext.sharedContext.packs
//            let tempgroups = BaseContext.sharedContext.groups
            
//            print("temppacks: \(temppacks)")
//            print("tempgroups: \(tempgroups)")
            
            let packsInCourses = BaseContext.sharedContext.packsInCourses
            
//            print("packsInCourses: \(packsInCourses)")
            
            let course = packsInCourses[(indexPath?.section)!]
            let pack = course.packs?[(indexPath?.row)!]
//            let groups = pack?.groups
            
            let groupIds = BaseContext.sharedContext.packToGroups.filter({$0.packId == pack?.id}).map{$0.groupId}
            
            let groups = BaseContext.sharedContext.groups.filter({groupIds.contains($0.id)})
            
            viewController.updateWithGroups(groups: groups, courseName: self.selectedSectionText, packType: self.selectedLabelText, packId: (pack?.id)!)

//            let button = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
//            self.navigationItem.backBarButtonItem = button
        }
    }
    
    func formHeaderTitle(indexPath: IndexPath) -> String {
        
        let packsInCourses = BaseContext.sharedContext.packsInCourses
        let course = packsInCourses[indexPath.section]
        let courseName = course.courseNameForYear()
        let term = BaseContext.sharedContext.terms.filter{ $0.id == course.termId }.first
        let allSubjects = BaseContext.sharedContext.subjects
        let subject = allSubjects.filter{ $0.id == term?.subjectId }.first
        
        return (subject?.name)! + " " + (term?.name)! + " " + courseName
    }
    
    func formSubjectHeaderTitle(indexPath: IndexPath) -> String {
        
        let packsInCourses = BaseContext.sharedContext.packsInCourses
        let course = packsInCourses[indexPath.section]
        let term = BaseContext.sharedContext.terms.filter{ $0.id == course.termId }.first
        let allSubjects = BaseContext.sharedContext.subjects
        let subject = allSubjects.filter{ $0.id == term?.subjectId }.first
        
        return subject!.name
    }
    
    func formCellTitle(indexPath: IndexPath) -> String {
        let course = BaseContext.sharedContext.packsInCourses[indexPath.section]
        let pack = course.packs?[indexPath.row]
        return (pack?.groupsNames())! + " - " + (pack?.stringType())!
    }
}
