//
//  RatingItemsViewController.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 30.01.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

class RatingItemsViewController: UITableViewController, StudentRatingTableViewControllerDismissed {

    struct StudentRatingModel {
        let student: Student
        let ratingValues: [Int]
    }
    
    let courseId: Int
    let packId: Int
//    let students: [Student]
//    var ratingItems: [RatingItem] = []
    var studentRatingModels: [StudentRatingModel] = []
    
    
    init(courseId: Int, packId: Int) {
        self.packId = packId
        self.courseId = courseId
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Бонусы"
        self.tableView.tableFooterView = UIView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(cancelPressed))
        tableView.register(RatingItemsTableViewCell.self)
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupRatingModels()
        
        self.tableView.reloadData()
    }
    
    func cancelPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupRatingModels() {
        studentRatingModels = []
        
        let pack = BaseContext.sharedContext.packs.first(where: {$0.id == packId})!
        let students = pack.groups![0].students!
        
        for student in students {
            let ratingValues = BaseContext.sharedContext.ratingItems
                .filter({$0.courseId == self.courseId
                    && $0.studentId == student.id
                    && $0.deleted == false})
                .map({$0.value})
            studentRatingModels.append(StudentRatingModel(student: student, ratingValues: Array(ratingValues)))
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentRatingModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RatingItemsTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)

        let ratingModel = studentRatingModels[indexPath.row]
        
        cell.updateWithRatingSummary(studentNumber: indexPath.row+1, student: ratingModel.student, ratingValues: ratingModel.ratingValues)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let ratingModel = studentRatingModels[indexPath.row]
        
        let studentRatingTableViewController = StudentRatingTableViewController(student: ratingModel.student, courseId: self.courseId)
        studentRatingTableViewController.delegate = self
        self.navigationController?.pushViewController(studentRatingTableViewController, animated: true)
    }
    
    func studentRatingControllerDidDismissed() {
        self.tableView.reloadData()
    }
    
    func studentRatingWasUpdated(ratingItem: RatingItem) {
//        self.ratingItems.append(ratingItem)
        self.tableView.reloadData()
    }
    
}

