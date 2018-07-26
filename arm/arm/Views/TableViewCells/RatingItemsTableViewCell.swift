//
//  RatingItemsTableViewCell.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 30.01.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

class RatingItemsTableViewCell: UITableViewCell, NibLoadableView {

    @IBOutlet weak var studentNumberLabel: UILabel!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var ratingSummaryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateWithRatingSummary(studentNumber: Int, student: Student, ratingValues: [Int]) {
        self.studentNumberLabel.text = "\(studentNumber)."
        self.studentNameLabel.text = student.shortName
        
        if ratingValues.count == 0 {
            self.ratingSummaryLabel.textColor = UIColor.lightGray
            self.ratingSummaryLabel.text = "-"
            return
        }
        
        let ratingSum = ratingValues.reduce(0) { (summary, item) -> Int in
            return summary + item
        }
        
        if (ratingSum > 0) {
            self.ratingSummaryLabel.textColor = ColorsHelper.green()
            self.ratingSummaryLabel.text = "+\(ratingSum)"
        }
        else if (ratingSum < 0){
            self.ratingSummaryLabel.textColor = ColorsHelper.red()
            self.ratingSummaryLabel.text = "\(ratingSum)"
        }
        else {
            self.ratingSummaryLabel.textColor = UIColor.lightGray
            self.ratingSummaryLabel.text = "0"
        }
    }
    
}
