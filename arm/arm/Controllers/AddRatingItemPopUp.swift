//
//  AddRatingItemPopUp.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 07.02.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

class AddRatingItemPopUp: UIViewController {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var commentTextView: KMPlaceholderTextView!
    
    var isPositive: Bool?
    var studentId: Int?
    var courseId: Int?
    var ratingTypeId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.placeholder = "Комментарий"
        commentTextView.delegate = self
        
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentTextView.layer.borderWidth = 0.5
        commentTextView.layer.cornerRadius = 5.0
        
        self.setupSlider()
    }
    
    func update(isPositive: Bool, studentId: Int, courseId: Int, ratingTypeId: Int) {
        self.isPositive = isPositive
        self.studentId = studentId
        self.courseId = courseId
        self.ratingTypeId = ratingTypeId
    }
    
    func setupSlider() {
        if (self.isPositive)! {
            self.valueSlider.minimumValue = 1
            self.valueSlider.maximumValue = 5
            self.valueSlider.value = 3
        }
        else {
            self.valueSlider.minimumValue = -5
            self.valueSlider.maximumValue = -1
            self.valueSlider.value = -3
        }
        self.valueLabel.text = "\(Int(self.valueSlider.value))"
    }
    
    @objc func endEditing() {
        view.endEditing(true)
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.valueLabel.text = "\(Int(sender.value))"
    }
}

extension AddRatingItemPopUp: UITextViewDelegate {
   
}
