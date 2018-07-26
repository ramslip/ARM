//
//  VariantSelectionViewController.swift
//  arm
//
//  Created by Victor Kalevko on 07.01.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import PinLayout

class VariantSelectionViewController: UITableViewController, UITextFieldDelegate {

    let packId: Int
    let toolbar = UIToolbar()
    let switchView = LabelWithSwitchView()
    var editingTextField: UITextField?
    
    let students: [Student]
    
    init(packId: Int) {
        self.packId = packId
        
        let pack = BaseContext.sharedContext.packs.first(where: {$0.id == packId})!
        students = pack.groups![0].students!
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let items = [UIBarButtonItem(title: "Пред.", style: .plain, target: self, action: #selector(prevItemPressed)),
                     UIBarButtonItem(title: "След.", style: .plain, target: self, action: #selector(nextItemPressed)),
                     UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                     UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toolbarDonePressed))]
        
        toolbar.setItems(items, animated: false)
        toolbar.tintColor = ColorsHelper.blue()
        
        self.title = "Выбрать варианты"
        
        tableView.register(VariantSelectionTableViewCell.self)
        tableView.dataSource = self
        
        switchView.bottomSeparator.backgroundColor = tableView.separatorColor
        switchView.topSeparator.backgroundColor = tableView.separatorColor
        switchView.isEnabled = true
        switchView.title = "Использовать варианты"
        switchView.switchControl.addTarget(self, action: #selector(onSwitchChanged), for: .valueChanged)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(doneButtonPressed))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        
    }
    
    var variantsIsEnabled: Bool {
        return switchView.switchControl.isOn
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VariantSelectionTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        
        toolbar.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44)
        
        let student = students[indexPath.row]
        
        cell.label.text = student.surname + " " + student.name
        
        cell.textField.tag = indexPath.row
        cell.textField.inputAccessoryView = toolbar
        cell.textField.delegate = self
        cell.textField.text = "\(indexPath.row + 1)"
        cell.textField.isEnabled = variantsIsEnabled
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switchView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50.0)
        return switchView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editingTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        editingTextField = nil
    }
    
    func prevItemPressed() {
        if let textField = editingTextField {
            navigateToTextFieldWith(tag: textField.tag - 1)
        }
    }
    
    func nextItemPressed() {
        if let textField = editingTextField {
            navigateToTextFieldWith(tag: textField.tag + 1)
        }
    }
    
    func navigateToTextFieldWith(tag textFieldTag: Int){
        let visibleCells = self.tableView.visibleCells
        
        for cell in visibleCells {
            if let variantCell = cell as? VariantSelectionTableViewCell {
                if variantCell.textField.tag == textFieldTag {
                    variantCell.textField.becomeFirstResponder()
                    return
                }
            }
        }
    }
    
    func toolbarDonePressed() {
        self.view.endEditing(true)
    }
    
    func onSwitchChanged(switch: UISwitch){
        self.view.endEditing(true)
        self.tableView.reloadData()
    }
    
    func doneButtonPressed() {
        //TODO: save changes
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
