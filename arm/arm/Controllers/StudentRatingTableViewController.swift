//
//  StudentRatingTableViewController.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 31.01.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

protocol StudentRatingTableViewControllerDismissed {
    func studentRatingControllerDidDismissed()
    func studentRatingWasUpdated(ratingItem: RatingItem)
}

class StudentRatingTableViewController: UITableViewController, AddRatingTableViewControllerDismissed {

    let student: Student
    var ratingItems: [RatingItem]
    let courseId: Int
    var delegate: StudentRatingTableViewControllerDismissed?
    
    let emptyContentLabel = UILabel()
    
    init(student: Student,  courseId: Int) {
        self.student = student
        self.courseId = courseId
        
        self.ratingItems = BaseContext.sharedContext.ratingItems.filter({$0.courseId == courseId && $0.studentId == student.id && !$0.deleted})
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.student.shortName
        self.tableView.tableFooterView = UIView()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRating))
        
        tableView.register(StudentRatingTableViewCell.self)
        tableView.dataSource = self
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.view.addSubview(self.emptyContentLabel)
        
        emptyContentLabel.numberOfLines = 0
        emptyContentLabel.textAlignment = .center
        emptyContentLabel.textColor = UIColor.gray
        emptyContentLabel.text = "У студента \(self.student.shortName) пока нет бонусов"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emptyContentLabel.pin.all().marginHorizontal(20).marginTop(-100)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEmptyLabelVisibility(false)
    }
    
    func updateEmptyLabelVisibility (_ animated: Bool){
        let targetAlpha = self.ratingItems.count == 0 ? CGFloat(1.0) : CGFloat(0.0)
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.emptyContentLabel.alpha = targetAlpha
            })
        }
        else {
            emptyContentLabel.alpha = targetAlpha
        }
    }
    
    func addRating() {
        let addRatingTableViewController = AddRatingTableViewController(student: self.student, courseId: self.courseId)
        addRatingTableViewController.delegate = self
        
        let navigationController = NavigationController(rootViewController: addRatingTableViewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func addRatingControllerDidDismissed() {
        self.tableView.reloadData()
    }
    
    func addedNewRating(rating: RatingItem) {
        self.ratingItems.append(rating)
        self.tableView.reloadData()
//        self.delegate?.studentRatingWasUpdated(ratingItem: rating)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ratingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StudentRatingTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let ratingItem = self.ratingItems[indexPath.row]
        cell.updateWithRatingItem(rating: ratingItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            let alert = UIAlertController(title: "Удалить бонус?", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [unowned self] (_) in
                
                self.deleteRatingItem(ratingItem: self.ratingItems[indexPath.row])
                self.ratingItems.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.updateEmptyLabelVisibility(true)
            }))
            
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func deleteRatingItem(ratingItem: RatingItem) {
        realmInstance.beginWrite()
        if (ratingItem.serverId == 0) {
            realmInstance.delete(ratingItem)
            
            if let index = BaseContext.sharedContext.ratingItems.index(of: ratingItem) {
                BaseContext.sharedContext.ratingItems.remove(at: index)
            }
        }
        else {
            ratingItem.deleted = true
            realmInstance.add(ratingItem, update: true)
        }
        try! realmInstance.commitWrite()
    }
}
