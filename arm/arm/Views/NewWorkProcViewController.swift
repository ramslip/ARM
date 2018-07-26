//
//  NewWorkProcViewController.swift
//  arm
//
//  Created by Victor Kalevko on 06.01.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import PinLayout
import FSCalendar

class LabelWithSwitchView: UIView {
    
    let label = UILabel()
    let switchControl = UISwitch()
    
    let topSeparator = UIView()
    let bottomSeparator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        addSubview(switchControl)
        
        addSubview(topSeparator)
        addSubview(bottomSeparator)
        
        switchControl.tintColor = ColorsHelper.blue()
        switchControl.onTintColor = ColorsHelper.blue()
        
        self.backgroundColor = ColorsHelper.lightBlue()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        switchControl.pin.right().vCenter().margin(8)
        label.pin.topLeft().bottom().left(of: switchControl).margin(8)
        
        topSeparator.pin.topRight().left().height(0.5)
        bottomSeparator.pin.bottomRight().left().height(0.5)
    }
    
    var title: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var isEnabled: Bool {
        get {
            return switchControl.isEnabled
        }
        set {
            switchControl.isEnabled = newValue
        }
    }
}

class NewWorkProcViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDelegate {

    let tableView = UITableView()
    let switchView = LabelWithSwitchView()
    
    struct WorkItem {
        let workId: Int
        let workName: String
        let workProc: WorkProc
    }
    
    let packId: Int
    
    typealias IntBlock = (Int) -> ()
    let donePressedBlock: IntBlock
    
    var workItems = [WorkItem]()
    var selectedItemIndex: Int = NSNotFound
    var selectedDate: Date?
    
    init(with packId: Int, donePressedBlock: @escaping IntBlock ) {
        self.packId = packId
        self.donePressedBlock = donePressedBlock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Выдать работу"
        
        tableView.register(UITableViewCell.self)
        tableView.register(CalendarTableViewCell.self)
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        switchView.bottomSeparator.backgroundColor = tableView.separatorColor
        switchView.topSeparator.backgroundColor = tableView.separatorColor
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.view.addSubview(tableView)

        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelPressed))
       // self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(donePressed))
        
        switchView.isEnabled = false
        switchView.title = "Указать крайний срок"
        switchView.switchControl.addTarget(self, action: #selector(onSwitchChanged), for: .valueChanged)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let notStartedWorkProcs = BaseContext.sharedContext.workProcs.filter({($0.startDate == nil || $0.state == 1) && $0.packId == self.packId})
        
        for workProc in notStartedWorkProcs {
            let work = BaseContext.sharedContext.works.first(where: {$0.id == workProc.workId})!
            
            workItems.append(WorkItem(workId: work.id, workName: work.name, workProc: workProc))
        }
        
        workItems.sort(by: {$0.0.workId < $0.1.workId})
    }
    
    func cancelPressed(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func donePressed(){
        
        guard selectedItemIndex != NSNotFound else {
            return
        }
        
        let selectedWorkProc = self.workItems[selectedItemIndex].workProc
        var endDate: Date?
        
        if shouldDisplayCalendar {
            endDate = selectedDate
        }
        
        RealmClient.sharedClient.start(workProc: selectedWorkProc, with: endDate)
        self.donePressedBlock(selectedWorkProc.serverId)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.pin.all()
    }
    
    var shouldDisplayCalendar: Bool {
        return switchView.switchControl.isOn
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
             return workItems.count
        }
        else {
            if shouldDisplayCalendar {
                return 1
            }
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let calendarCell: CalendarTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            
            calendarCell.calendarView.firstWeekday = 2
            calendarCell.calendarView.tintColor = ColorsHelper.blue()
            calendarCell.calendarView.delegate = self
            return calendarCell
        }
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.textLabel?.text = workItems[indexPath.row].workName
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 50
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 1 {
            return nil
        }
        
        switchView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        return switchView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switchView.isEnabled = true
        self.selectedItemIndex = indexPath.row
        updateDoneButtonEnabledState()
    }
    
    func updateDoneButtonEnabledState(){
        
        var enabled = false
        
        if self.selectedItemIndex != NSNotFound {
            if shouldDisplayCalendar {
                if selectedDate != nil {
                    enabled = true
                }
            }
            else {
                enabled = true
            }
        }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = enabled
    }
    
    func onSwitchChanged(switch: UISwitch){
        
        let calendarIndexPath = IndexPath(row: 0, section: 1)
        
        if shouldDisplayCalendar {
            tableView.beginUpdates()
            tableView.insertRows(at: [calendarIndexPath], with: .automatic)
            tableView.endUpdates()
            
            tableView.scrollToRow(at: calendarIndexPath, at: .bottom, animated: true)
        }
        else {
            tableView.beginUpdates()
            tableView.deleteRows(at: [calendarIndexPath], with: .automatic)
            tableView.endUpdates()
        }
        
        updateDoneButtonEnabledState()
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        return indexPath.section == 0
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        updateDoneButtonEnabledState()
    }
}

