//
//  AddRatingTableViewController.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 07.02.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import PopupDialog

protocol AddRatingTableViewControllerDismissed {
    func addRatingControllerDidDismissed()
    func addedNewRating(rating: RatingItem)
}

class AddRatingTableViewController: UITableViewController {

    let student: Student
    let courseId: Int
    let ratingTypes: [RatingType]
    var delegate: AddRatingTableViewControllerDismissed?

    init(student: Student, courseId: Int) {
        self.student = student
        self.courseId = courseId
        self.ratingTypes = BaseContext.sharedContext.ratingTypes
        self.ratingTypes.sort { $0.isPositive && !$1.isPositive }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Добавить бонус"
        self.tableView.tableFooterView = UIView()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))

        tableView.register(AddRatingTableViewCell.self)
        tableView.dataSource = self
    }

    func cancel() {
        self.delegate?.addRatingControllerDidDismissed()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ratingTypes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AddRatingTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let ratingType = self.ratingTypes[indexPath.row]
        cell.updateWithTitle(title: ratingType.name, isPositive: ratingType.isPositive)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ratingType = self.ratingTypes[indexPath.row]
        self.openDialog(isPositive: ratingType.isPositive, ratingTypeId: ratingType.id)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func openDialog(isPositive: Bool, ratingTypeId: Int) {
        let addRatingDialog = AddRatingItemPopUp(nibName: "AddRatingItemPopUp", bundle: nil)
        addRatingDialog.update(isPositive: isPositive, studentId: self.student.id, courseId: self.courseId, ratingTypeId: ratingTypeId)

        let popup = PopupDialog(viewController: addRatingDialog, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false)
        let cancelButton = CancelButton(title: "Отмена") {
            popup.dismiss()
        }
        cancelButton.titleColor = ColorsHelper.red()
        let doneButton = DefaultButton(title: "Добавить", height: 60) {
            self.addRating(value: Int(addRatingDialog.valueSlider.value), comment: addRatingDialog.commentTextView.text!, typeId: ratingTypeId)
            self.cancel()
        }
        popup.addButtons([cancelButton, doneButton])
        present(popup, animated: true, completion: nil)
    }
    
    func addRating(value: Int, comment: String, typeId: Int) {
        let ratingItem = RatingItem()
        ratingItem.comment = comment
        ratingItem.studentId = self.student.id
        ratingItem.courseId = self.courseId
        ratingItem.date = Date()
        ratingItem.serverId = 0
        ratingItem.typeId = typeId
        ratingItem.value = value
        
        try! realmInstance.write {
            let maxId = BaseContext.sharedContext.ratingItems.map{$0.id}.max()
            ratingItem.id = maxId! + 1
            realmInstance.add(ratingItem, update: false)
            BaseContext.sharedContext.ratingItems.append(ratingItem)
            self.delegate?.addedNewRating(rating: ratingItem)
        }
    }

}
