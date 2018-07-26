//
//  AddRatingTableViewCell.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 07.02.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

class AddRatingTableViewCell: UITableViewCell, NibLoadableView {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateWithTitle(title: String, isPositive: Bool) {
        self.titleLabel.text = title
        self.titleLabel.textColor = isPositive ? ColorsHelper.green() : ColorsHelper.red()
    }
}
