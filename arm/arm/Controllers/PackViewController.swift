//
//  PackViewController.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 23.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import SpreadsheetView
import TwicketSegmentedControl

class PackViewController: ViewController, TwicketSegmentedControlDelegate, NewLessonDateViewControllerDelegate, WorkProcUpdatedDelegate {

    struct SegmentItem {
        let title: String
        let controller: SpreadsheetViewController
    }
    
    var groups: [Group] = []
    var courseName: String?
    var packType: String?
    var packId: Int = 0
    var lessonsForPack : [Lesson] = []
    var isLection: Bool = true;
    var worksForPack: [WorkProc] = []
    
    @IBOutlet weak var spreadSheetView: SpreadsheetView!
    @IBOutlet weak var viewForSegmentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var segmentControl: TwicketSegmentedControl!
    
    var segmentItems: [SegmentItem] = []
    var titleView = NavigationItemTitleView()
    
    func updatePackViewController(work: Work, workProc: WorkProc) {
        for segmentItem in self.segmentItems {
            if let workProcController = segmentItem.controller as? WorkProcsSpreadsheetViewController {
                workProcController.updateWork(work: work, workProc: workProc)
            }
        }
        self.spreadSheetView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spreadSheetView.contentOffset = .zero
        spreadSheetView.register(PackCollectionViewCell.self)
        spreadSheetView.register(PackWorkProgressViewCell.self)
        spreadSheetView.register(PackWorkWithThemeProgressViewCell.self)
        spreadSheetView.register(HeaderWithSubtitleCell.self)
        spreadSheetView.bounces = true
        self.setupSegmentControl()
        
        updateSpreadsheetViewWithSelectedSegment()
        
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ios-more"), style: .plain, target: self, action: #selector(morePressed))
        self.navigationItem.setRightBarButton(moreButton, animated: true)
        
        self.navigationItem.titleView = titleView
        self.titleView.title = self.courseName
        self.titleView.subTitle = self.packType
    }
    
    func morePressed() {
        let alertController = UIAlertController(title: "Действия", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Добавить занятие", style: .default, handler: { (action) in
            self.showNewLessonDialog()
        }))
        
        if (!self.isLection) {
            
            alertController.addAction(UIAlertAction(title: "Выдать работу", style: .default, handler: { (action) in
                self.showNewWorkProcDialog()
            }))
            alertController.addAction(UIAlertAction(title: "Варианты", style: .default, handler: { (_) in
                
                self.showPackVariants()
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Бонусы", style: .default, handler: { (action) in
            self.showRatingItems()
        }))
        
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showUpdateVisitsDialog(lesson: Lesson) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let updateVisitsDialogViewController = storyboard.instantiateViewController(withIdentifier :"NewLessonDateViewController") as! NewLessonDateViewController
        updateVisitsDialogViewController.delegate = self
        updateVisitsDialogViewController.updateVisits(lesson: lesson, groups: self.groups)
        let navigation = UINavigationController(rootViewController: updateVisitsDialogViewController)
        self.present(navigation, animated: true, completion: nil)
    }
    
    func showNewLessonDialog() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newLessonDialogViewController = storyboard.instantiateViewController(withIdentifier :"NewLessonDateViewController") as! NewLessonDateViewController
        newLessonDialogViewController.delegate = self
        newLessonDialogViewController.updateWithCalendar(isCalendar: true)
        newLessonDialogViewController.groups = self.groups
        newLessonDialogViewController.packId = self.packId
        let navigation = NavigationController(rootViewController: newLessonDialogViewController)
        self.present(navigation, animated: true, completion: nil)
    }
    
    func showPackVariants() {
        let variantSelectionController = VariantSelectionViewController(packId: self.packId)
        let navigationController = NavigationController(rootViewController: variantSelectionController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func showRatingItems() {
        let pack = BaseContext.sharedContext.packs.first(where: {$0.id == self.packId})
        let ratingItemsViewController = RatingItemsViewController(courseId: (pack?.courseId)!, packId: self.packId)
        self.navigationController?.pushViewController(ratingItemsViewController, animated: true)
    }

    func showNewWorkProcDialog() {
        
        if BaseContext.sharedContext.workProcs.filter({($0.startDate == nil || $0.state == 1) && $0.packId == packId}).count == 0 {
            
            let alert = UIAlertController(title: "Все работы уже выданы", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
                popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
            }
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        let donePressedBlock = {[unowned self] (startedWorkProcId: Int) in
            
            let startedWorkProc = BaseContext.sharedContext.workProcs.first(where: {$0.serverId == startedWorkProcId && $0.state == 0})!
            
            self.worksForPack.append(startedWorkProc)
            
            for segment in self.segmentItems where segment.controller is WorkProcsSpreadsheetViewController {
                
                let workProcController = segment.controller as! WorkProcsSpreadsheetViewController
                
                workProcController.add(workProc: startedWorkProc)
            }
            
            self.spreadSheetView.reloadData()
        }
        
        let controller = NewWorkProcViewController(with: packId, donePressedBlock: donePressedBlock)
        
        let navigationController = NavigationController(rootViewController: controller)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func setupSegmentControl() {
        
        if self.segmentItems.count == 1 {
            self.segmentControl.isHidden = true
            self.viewForSegmentHeightConstraint.constant = 0
        }
        else {
            self.segmentControl.delegate = self
            let segmentItemNames = self.segmentItems.map{ $0.title }
            self.segmentControl.setSegmentItems(segmentItemNames)
            self.segmentControl.sliderBackgroundColor = ColorsHelper.blue()
        }
    }
    
    func updateSpreadsheetViewWithSelectedSegment(){
    
        let selectedItem = self.segmentItems[self.segmentControl.selectedSegmentIndex]
        spreadSheetView.dataSource = selectedItem.controller
        spreadSheetView.delegate = selectedItem.controller
    }
    
    func didSelect(_ segmentIndex: Int) {
        updateSpreadsheetViewWithSelectedSegment()
        self.spreadSheetView.reloadData()
    }

    func updateWithGroups(groups: [Group], courseName: String!, packType: String!, packId: Int) {
        self.groups = groups
        self.courseName = courseName
        self.packType = packType
        let pack = BaseContext.sharedContext.packs.filter{$0.id == packId}.first;
        self.isLection = pack?.type == 1;
        self.packId = packId
        
        self.lessonsForPack = BaseContext.sharedContext.lessons
            .filter{ $0.packId == self.packId && $0.deleted != true}
            .sorted() { $0.date.timeIntervalSince1970 < $1.date.timeIntervalSince1970 }
        
        if (!isLection) {
            self.worksForPack = BaseContext.sharedContext.workProcs
                .filter{$0.packId == self.packId && $0.startDate != nil && $0.state == 0}
                .sorted(by: {$0.0.startDate! < $0.1.startDate!})
        }
        
        if isLection {
            for group in groups {
                let groupLessonDataSource = LessonsSpreadsheetViewController(students: group.students!, lessons: lessonsForPack)
                groupLessonDataSource.delegate = self
                self.segmentItems.append(SegmentItem(title: group.name, controller: groupLessonDataSource))
            }
        }
        else {
            let lessonsDataSource = LessonsSpreadsheetViewController(students: groups[0].students!, lessons: lessonsForPack)
            lessonsDataSource.delegate = self
            
            let works = BaseContext.sharedContext.works
            let workProcsDataSource = WorkProcsSpreadsheetViewController(students: groups[0].students!, workProcs: self.worksForPack, works: works)
            workProcsDataSource.delegate = self
            
            self.segmentItems.append(SegmentItem(title: "Посещаемость", controller: lessonsDataSource))
            self.segmentItems.append(SegmentItem(title: "Работы", controller: workProcsDataSource))
        }
    }
    
    func lessonDidAdded(lesson: Lesson) {
        self.lessonsForPack.append(lesson)
        BaseContext.sharedContext.lessons.append(lesson)
        
        for segmentItem in self.segmentItems {
            if let lessonController = segmentItem.controller as? LessonsSpreadsheetViewController {
                lessonController.addLesson(lesson: lesson)
            }
        }
        
        self.spreadSheetView.reloadData()
    }
    
    func removeLesson(lesson: Lesson) {
        RealmClient.sharedClient.markLessonAsDeleted(lesson: lesson)
        
        if let indexOfLesson = self.lessonsForPack.index(of: lesson) {
            self.lessonsForPack.remove(at: indexOfLesson)
            
            for segmentItem in self.segmentItems {
                if let lessonController = segmentItem.controller as? LessonsSpreadsheetViewController {
                    lessonController.removeLesson(lesson: lesson)
                }
            }
            
            self.spreadSheetView.reloadData()
        }
    }
    
    func visitsDidUpdated(lesson: Lesson) {

        for segmentItem in self.segmentItems {
            if let lessonController = segmentItem.controller as? LessonsSpreadsheetViewController {
                lessonController.updateLesson(lesson: lesson)
            }
        }
        
        self.spreadSheetView.reloadData()
    }
    
}

extension PackViewController: LessonsSpreadsheetViewControllerDelegate, WorkProcsSpreadsheetViewControllerDelegate {
    
    func didSelect(lesson: Lesson) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Изменить посещаемость", style: .default, handler: { _ in
            self.showUpdateVisitsDialog(lesson: lesson);
        }))
        alert.addAction(UIAlertAction(title: "Удалить занятие", style: .destructive, handler: { _ in
            self.removeLesson(lesson: lesson)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func didSelect(workProc: WorkProc) {
        //TODO: show actions
    }
    
    func didSelect(studentProc: StudentWorkProc, workProc: WorkProc) {
     
        let workProcViewController = WorkProcViewController(nibName: "WorkProcViewController", bundle: nil)
        workProcViewController.delegate = self
        workProcViewController.studentId = studentProc.studentId
        workProcViewController.workProcId = workProc.serverId
        workProcViewController.groupId = groups[0].id
        workProcViewController.packId = workProc.packId
        
        self.navigationController?.pushViewController(workProcViewController, animated: true)
    }
}
