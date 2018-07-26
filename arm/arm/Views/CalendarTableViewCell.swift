//
//  CalendarTableViewCell.swift
//  arm
//
//  Created by Victor Kalevko on 06.01.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var calendarView: FSCalendar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension CalendarTableViewCell: NibLoadableView { }
