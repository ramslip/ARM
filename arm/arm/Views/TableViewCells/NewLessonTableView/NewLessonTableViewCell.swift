//
//  NewLessonTableViewCell.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 18.09.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

protocol NewLessonTableViewCellDelegate {
    func visitValueChanged(newValue: VisitValue, studentId: Int)
}

extension VisitValue{
    
    var selectedSegmentIndex: Int {
        switch self {
        case .important:
            return 0
        case .half:
            return 1
        case .none:
            return 2
        case .full:
            return 3
        }
    }
    
    var tintColor: UIColor{
        switch self {
        case .important:
            return ColorsHelper.visitBlue()
        case .half:
            return ColorsHelper.orange()
        case .none:
            return ColorsHelper.red()
        case .full:
            return ColorsHelper.green()
        }
    }
    
    var title: String{
        switch self {
        case .important:
            return "УВ"
        case .half:
            return "Н/+"
        case .none:
            return "Н"
        case .full:
            return "+"
        }
    }
    
    static func valueWith(segmentIndex: Int) -> VisitValue{
        switch segmentIndex {
        case 0:
            return .important
        case 1:
            return .half
        case 2:
            return .none
        case 3:
            return .full
        default:
            return .none
        }
    }
    
}


class NewLessonTableViewCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var delegate: NewLessonTableViewCellDelegate?
    var studentId: Int = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupSegmentControl()
    }
    
    @IBAction func visitValueChanged(_ sender: UISegmentedControl) {
        let newValue = VisitValue.valueWith(segmentIndex: self.segmentControl.selectedSegmentIndex)
        self.delegate?.visitValueChanged(newValue: newValue, studentId: self.studentId)
    }
    
    func setupSegmentControl() {
        
        (self.segmentControl.subviews[0] as UIView).tintColor = VisitValue.important.tintColor
        (self.segmentControl.subviews[1] as UIView).tintColor = VisitValue.half.tintColor
        (self.segmentControl.subviews[2] as UIView).tintColor = VisitValue.none.tintColor
        (self.segmentControl.subviews[3] as UIView).tintColor = VisitValue.full.tintColor
        
        self.segmentControl.setTitle(VisitValue.important.title, forSegmentAt: VisitValue.important.selectedSegmentIndex)
        self.segmentControl.setTitle(VisitValue.half.title, forSegmentAt: VisitValue.half.selectedSegmentIndex)
        self.segmentControl.setTitle(VisitValue.none.title, forSegmentAt: VisitValue.none.selectedSegmentIndex)
        self.segmentControl.setTitle(VisitValue.full.title, forSegmentAt: VisitValue.full.selectedSegmentIndex)
    }
    
}

extension NewLessonTableViewCell: NibLoadableView { }
