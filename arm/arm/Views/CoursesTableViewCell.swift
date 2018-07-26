//
//  CoursesTableViewCell.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 22.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

class CoursesTableViewCell: UITableViewCell {

    @IBOutlet weak var courseLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bgColorView = UIView()
        bgColorView.backgroundColor = ColorsHelper.lightBlue()
        self.selectedBackgroundView = bgColorView
    }
    
    func update(groupName: String, packType: String) {
        self.courseLabel.text = groupName + " - " + packType
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
