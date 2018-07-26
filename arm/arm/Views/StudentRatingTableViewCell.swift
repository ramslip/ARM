//
//  StudentRatingTableViewCell.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 31.01.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

class StudentRatingTableViewCell: UITableViewCell, NibLoadableView {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateWithRatingItem(rating: RatingItem) {
        guard let ratingType = realmInstance.objects(RatingType.self).first(where: {$0.id == rating.typeId}) else {
        
            print("[StudentRatingCellView] updateWithRatingItem: ratingType \(rating.typeId) not found")
            return
        }
        
        if rating.comment.count == 0 {
            self.commentLabel.text = nil
            self.commentLabel.isHidden = true
        }
        else {
            self.commentLabel.isHidden = false
            self.commentLabel.text = rating.comment
        }
        
        let dateFormatter = Utils.dateFormatterDayMonthYear
        self.dateLabel.text = dateFormatter.string(from: rating.date)
        
        if rating.value > 0 {
            self.valueLabel.textColor = ColorsHelper.green()
            self.valueLabel.text = "+\(rating.value) (\(ratingType.name))"
        }
        else {
            self.valueLabel.textColor = ColorsHelper.red()
            self.valueLabel.text = "\(rating.value) (\(ratingType.name))"
        }
        
    }
    
}
