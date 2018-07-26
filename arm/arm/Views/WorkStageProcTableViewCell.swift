//
//  WorkStageProcTableViewCell.swift
//  homework
//
//  Created by Victor Kalevko on 26.11.16.
//  Copyright © 2016 Victor Kalevko. All rights reserved.
//

import UIKit
import M13Checkbox

class WorkStageProcTableViewCell: UITableViewCell {
    @IBOutlet weak var checkBoxLeftConstraint: NSLayoutConstraint!

    @IBOutlet weak var label: UILabel!
    // Initialization code
    @IBOutlet weak var checkBox: M13Checkbox!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.checkBox.tintColor = ColorsHelper.blue()
        self.checkBox.boxType = .circle
        self.checkBox.stateChangeAnimation = .stroke
        self.checkBox.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}

extension WorkStageProcTableViewCell : NibLoadableView{
    
}
