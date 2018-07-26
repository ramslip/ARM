//
//  CoursesTableViewHeaderLabel.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 01.09.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

class CoursesTableViewHeaderLabel: UILabel {

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
