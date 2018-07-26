//
//  WorkProcViewController.swift
//  homework
//
//  Created by Victor Kalevko on 26.11.16.
//  Copyright © 2016 Victor Kalevko. All rights reserved.
//

import UIKit
import PinLayout

class SimpleDataSource: NSObject, UITableViewDataSource {
    
    let titles: [String]
    
    init(titles: [String]){
        self.titles = titles
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell: UITableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.textLabel?.text = self.titles[indexPath.row]
        
        return cell
    }
    
}

@objc protocol WorkProcUpdatedDelegate {
    @objc optional func updatePackViewController(work: Work, workProc: WorkProc)
}

class WorkProcViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var delegate: WorkProcUpdatedDelegate?
    var dataSource : WorkProcDataSource!
    
    var workProcId: Int = 0
    var studentId: Int = 0
    var groupId: Int = 0
    var packId: Int = 0
    var selectedWorkName = ""
    
    let workTitleView = WorkTitleView()
    var completionView = WorkCompletionView()
    
    let leftSelectionTableView = UITableView(frame: CGRect.zero, style: .plain)
    let rightSelectionTableView = UITableView(frame: CGRect.zero, style: .plain)
    
    let selectionOverlayView = UIView()
    
    var studentsDataSource: SimpleDataSource!
    var workProcsDataSource: SimpleDataSource!
    
    let markTitles: [(Int,String)] = [(1, "Плохо"), (2, "Неуд."), (3, "Удовлетворительно"), (4 , "Хорошо"), (5, "Отлично")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectionOverlayView.addSubview(leftSelectionTableView)
        selectionOverlayView.addSubview(rightSelectionTableView)
        selectionOverlayView.backgroundColor = .white
        self.view.addSubview(selectionOverlayView)
        selectionOverlayView.isHidden = true
        
        leftSelectionTableView.register(UITableViewCell.self)
        rightSelectionTableView.register(UITableViewCell.self)
        
        if workProcId == 0 || studentId == 0 || groupId == 0{
            fatalError()
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        let student = BaseContext.sharedContext.students.first(where: {$0.id == self.studentId})!
        
        self.title = student.surname + " " + student.name
        
        let studentTitles = BaseContext.sharedContext.groups.first(where: {$0.id == groupId})!.students!.map({$0.shortName})
        studentsDataSource = SimpleDataSource(titles: studentTitles)
        rightSelectionTableView.dataSource = studentsDataSource
        
        let workIds = BaseContext.sharedContext.workProcs
            .filter({$0.packId == self.packId && $0.startDate != nil})
            .map({$0.workId})
        
        let worksNames = BaseContext.sharedContext.works
            .filter({workIds.contains($0.id)})
            .map({$0.name})
        
        workProcsDataSource = SimpleDataSource(titles: worksNames)
        leftSelectionTableView.dataSource = workProcsDataSource
        
        setupDataSource()
        
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self;
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(cancelPressed))

        //TODO: сделать нормальный экран переключения с UISegmentControl и колбэком
//        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ios-more"), style: .plain, target: self, action: #selector(morePressed))
//        self.navigationItem.setRightBarButton(moreButton, animated: true)
    }
    
    func cancelPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let workProc = BaseContext.sharedContext.workProcs.first(where: {$0.serverId == self.workProcId})!
        let work = BaseContext.sharedContext.works.first(where: {$0.id == workProc.workId})!
        self.delegate?.updatePackViewController!(work: work, workProc: workProc)
    }
    
    func morePressed(){
        self.selectionOverlayView.isHidden = !self.selectionOverlayView.isHidden
    }
    
    override func viewDidLayoutSubviews() {
        
        selectionOverlayView.pin.all()
        leftSelectionTableView.pin.topLeft().bottom().width(50%)
        rightSelectionTableView.pin.topRight().bottom().width(50%)
    }
    
    func setupDataSource() {
        
        var array = Array<WorkProcItem>()
        
        let workProc = realmInstance.objects(WorkProc.self).toArray().first(where: {$0.serverId == self.workProcId})!
        
        let studentProc = workProc.studentWorkProcs.first(where: {$0.studentId == self.studentId})!
        
        let work = BaseContext.sharedContext.works.first(where: {$0.id == workProc.workId})!
        selectedWorkName = work.name
        
        workTitleView.title = selectedWorkName
        
        if (work.hasThemes) {
            if (studentProc.workThemeId == 0) {
                workTitleView.theme = "Тема не выбрана";
            }
            else {
                workTitleView.theme = "Тема: " + (BaseContext.sharedContext.workThemes.first(where: {$0.serverId == studentProc.workThemeId})?.name)!
            }
        }
        else {
            workTitleView.theme = nil
        }
        
        setupCompletionView(studentProc: studentProc, workTypeId: work.workControlTypeId)
        
        let workStages = BaseContext.sharedContext.workStages.filter({$0.workId == work.id})
        
        let firstLevelStages = workStages.filter({$0.parentWorkStageId == 0}).sorted(by: {$0.0.id < $0.1.id})
        var secondLevelStages = [WorkStage]()
        for firstLevelStage in firstLevelStages {
            if let secondLevelStage = workStages.filter({ $0.parentWorkStageId == firstLevelStage.id }).first {
                secondLevelStages.append(secondLevelStage)
            }
        }
        
        for stage in firstLevelStages {
            if (studentProc.studentStageProcs.count == 0) {
                continue;
            }
            let stageProc =
                studentProc.studentStageProcs.first(where: {$0.workStageId == stage.id})!
            
            array.append(WorkProcItem(stageName: stage.name, isSubStage: false, isDone: stageProc.completed, workStageId: stageProc.workStageId, studentWorkProcId: stageProc.studentWorkProcId, id: stageProc.id, workId: work.id, studentId: self.studentId))
            
            let subStages = secondLevelStages.filter({$0.parentWorkStageId == stage.id}).sorted(by: {$0.0.id < $0.1.id})
            
            for substage in subStages {
                let subStageProc =
                    studentProc.studentStageProcs.first(where: {$0.workStageId == substage.id})!
                
                array.append(WorkProcItem(stageName: substage.name, isSubStage: true, isDone: subStageProc.completed, workStageId: 0, studentWorkProcId: substage.workId, id: subStageProc.id, workId: work.id, studentId: self.studentId))
            }
        }
        
        dataSource = WorkProcDataSource(tableView: self.tableView, workProcItems: array)
        
        let workIsCompleted = studentProc.completion > 0
        dataSource.itemsEnabled = !workIsCompleted
    }
    
    func setupCompletionView(studentProc: StudentWorkProc, workTypeId: Int){
        completionView.ratingItemsButton.removeTarget(nil, action: nil, for: .allEvents)
        completionView.ratingItemsButton.addTarget(self, action: #selector(openStudentRating), for: .touchUpInside)

        if studentProc.completion > 0 {
            completionView.completionButton.removeTarget(nil, action: nil, for: .allEvents)
            completionView.buttonTitle = "Отменить"
            completionView.completionButton.addTarget(self, action: #selector(showCancelCompletionWorkAlert), for: .touchUpInside)
            
            if workTypeId == 1 {
                completionView.labelTitle = "Работа принята ✓"
            }
            else if workTypeId == 2 {
                completionView.labelTitle = "Оценка за работу: \(studentProc.completion)"
            }
        }
        else {
            completionView.labelTitle = nil
            
            if workTypeId == 1 {
                completionView.buttonTitle = "Зачесть"
                
                completionView.completionButton.addTarget(self, action: #selector(completeStudentProcWith), for: .touchUpInside)
            }
            else if workTypeId == 2 {
                completionView.buttonTitle = "Поставить оценку"
                
                completionView.completionButton.addTarget(self, action: #selector(showCompleteStudentWorkAlert), for: .touchUpInside)
            }
        }
    }
    
    func openStudentRating() {
        let pack = BaseContext.sharedContext.packs.filter({$0.id == self.packId}).first
        
        let student = BaseContext.sharedContext.students.filter({$0.id == self.studentId}).first
        let studentRatingTableViewController = StudentRatingTableViewController(student: student!, courseId: (pack?.courseId)!)
        self.navigationController?.pushViewController(studentRatingTableViewController, animated: true)
    }
    
    func showCompleteStudentWorkAlert() {
        let alert = UIAlertController(title: "Поставить оценку", message: nil, preferredStyle: .actionSheet)
        
        for pair in markTitles.reversed() {
            alert.addAction(UIAlertAction(title: pair.1, style: .default, handler: { (_) in
                self.completeStudentProcWith(value: pair.0)
            }));
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
            popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func completeStudentProcWith(value: Int) {
        let workProc = realmInstance.objects(WorkProc.self).first(where: {$0.serverId == self.workProcId})
        let studentWorkProc = workProc?.studentWorkProcs.first(where: {$0.studentId == self.studentId})
        let work = BaseContext.sharedContext.works.first(where: {$0.id == workProc?.workId})!

        realmInstance.beginWrite()
        
        studentWorkProc?.completion = work.workControlTypeId == 1 ? 1 : value
        studentWorkProc?.completionDate = Utils.string(from: Date())
        studentWorkProc?.changed = true
        
        for stageProc in (studentWorkProc?.studentStageProcs)! {
            stageProc.changed = true
        }
        
        try! realmInstance.commitWrite()
        selectedWorkName = work.name
        completionView = WorkCompletionView()
        self.setupCompletionView(studentProc: studentWorkProc!, workTypeId: work.workControlTypeId)
        
        dataSource.itemsEnabled = false
        self.tableView.reloadData()
    }
    
    
    func showCancelCompletionWorkAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Отменить прием работы", style: .destructive, handler: { (_) in
            self.cancelCompletionWork()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func cancelCompletionWork() {
        let workProc = realmInstance.objects(WorkProc.self).first(where: {$0.serverId == self.workProcId})
        let studentWorkProc = workProc?.studentWorkProcs.first(where: {$0.studentId == self.studentId})
        realmInstance.beginWrite()
        
        studentWorkProc?.completion = 0
        studentWorkProc?.completionDate = ""
        studentWorkProc?.changed = true
        
        for stageProc in (studentWorkProc?.studentStageProcs)! {
            stageProc.changed = true
        }
        
        try! realmInstance.commitWrite()
        let work = BaseContext.sharedContext.works.first(where: {$0.id == workProc?.workId})!
        selectedWorkName = work.name
        completionView = WorkCompletionView()
        self.setupCompletionView(studentProc: studentWorkProc!, workTypeId: work.workControlTypeId)
        
        dataSource.itemsEnabled = true
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        dataSource.workProcItems[indexPath.row].toggleDone();
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return completionView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return completionView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width, height: .greatestFiniteMagnitude)).height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return workTitleView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let size: CGSize = CGSize(width: UIScreen.main.bounds.size.width, height: .greatestFiniteMagnitude)
        
        return workTitleView.sizeThatFits(size).height
    }
    
}

extension UILabel {
    
    func findHeight(widthValue: CGFloat) -> CGFloat {
        let text = self.text ?? ""
        let font = self.font
        
        var size = CGSize.zero
        
        let frame = text.boundingRect(with: CGSize(width: widthValue, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        size = CGSize(width: frame.size.width, height: frame.size.height + 1)
        
        return size.height
    }

}
