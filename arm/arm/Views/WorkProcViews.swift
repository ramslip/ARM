//
//  WorkProcViews.swift
//  arm
//
//  Created by Victor Kalevko on 16.02.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import SwiftyButton

extension UIColor {
    class var separator: UIColor {
        return UIColor(white: 0.79, alpha: 1)
    }
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}

class WorkTitleView: UIView {
    
    private let titleLabel = UILabel()
    private let themeLabel = UILabel()
    
    private let kMarginDefault: CGFloat = 10
    
    private let separator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(titleLabel)
        self.addSubview(themeLabel)
        self.addSubview(separator)
        
        separator.backgroundColor = .separator
        
        titleLabel.textColor = UIColor.darkGray
        titleLabel.numberOfLines = 0
        
        themeLabel.textColor = UIColor.darkGray
        themeLabel.numberOfLines = 0
        
        self.backgroundColor = .white
    }
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
            titleLabel.sizeToFit()
            setNeedsLayout()
        }
    }
    
    var theme: String? {
        get {
            return themeLabel.text
        }
        set {
            themeLabel.text = newValue
            themeLabel.sizeToFit()
            
            if let themeString = newValue {
                themeLabel.isHidden = themeString.count == 0
            }
            else {
                themeLabel.isHidden = true
            }
            setNeedsLayout()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.separator.pin.bottomLeft().right().height(0.5)
        
        let maxWidth = self.frame.size.width - kMarginDefault * 2
        
        let titleLabelHeight = self.titleLabel.findHeight(widthValue: maxWidth)
        
        self.titleLabel.pin.topLeft().right()
            .height(titleLabelHeight)
            .margin(kMarginDefault)
        
        if !self.themeLabel.isHidden {
            let themeLabelHeight = self.themeLabel.findHeight(widthValue: maxWidth)
            
            self.themeLabel.pin.below(of: self.titleLabel)
                .left()
                .right()
                .marginHorizontal(kMarginDefault)
                .marginTop(kMarginDefault)
                .marginBottom(kMarginDefault)
                .height(themeLabelHeight)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var totalHeight: CGFloat = 0
        let maxWidth = size.width - kMarginDefault * 2
        let titleLabelHeight = self.titleLabel.findHeight(widthValue: maxWidth)
        
        
        if self.themeLabel.isHidden {
            totalHeight = titleLabelHeight + kMarginDefault * 2
        }
        else {
            let themeLabelHeight = self.themeLabel.findHeight(widthValue: maxWidth)
            totalHeight = themeLabelHeight + titleLabelHeight + kMarginDefault * 3
        }
        
        return CGSize(width: size.width, height: totalHeight)
    }
}

class WorkCompletionView: UIView {
    
    let completionLabel = UILabel()
    let completionButton: FlatButton
    let ratingItemsButton: FlatButton
    
    private let separator = UIView()
    
    override init(frame: CGRect) {
        self.completionButton = FlatButton()
        self.completionButton.color = ColorsHelper.blue()
        self.completionButton.highlightedColor = ColorsHelper.blue().darker(by: 10)!
        
        self.ratingItemsButton = FlatButton()
        self.ratingItemsButton.color = .white
        self.ratingItemsButton.highlightedColor = UIColor.white.darker(by: 10)!
        self.ratingItemsButton.borderColor = ColorsHelper.blue()
        self.ratingItemsButton.borderWidthPreset = .border2
        self.ratingItemsButton.cornerRadiusPreset = .cornerRadius2
        
        self.ratingItemsButton.setTitleColor(ColorsHelper.blue(), for: .normal)
        
        self.separator.backgroundColor = .separator
        
        super.init(frame: frame)
        self.addSubview(completionLabel)
        self.addSubview(completionButton)
        self.addSubview(ratingItemsButton)
        self.addSubview(separator)
        
        self.backgroundColor = .white
        
        completionLabel.textColor = .darkGray
    
        ratingItemsButton.setTitle("Бонусы студента", for: .normal)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var labelTitle: String? {
        get {
            return completionLabel.text
        }
        set {
            completionLabel.text = newValue
        }
    }
    
    var buttonTitle: String? {
        get {
            return completionButton.title(for: .normal)
        }
        set {
            completionButton.setTitle(newValue, for: .normal)
        }
    }
    
    private let kButtonHeight: CGFloat = 40
    private let kLabelHeight: CGFloat = 20
    private let kMarginDefault: CGFloat = 10
    
    override func layoutSubviews() {
        self.separator.pin.topLeft().right().height(0.5)
        
        self.completionLabel.sizeToFit()
        self.completionButton.sizeToFit()
        self.ratingItemsButton.sizeToFit()
        
        self.completionLabel.pin.topLeft().right().height(kLabelHeight).margin(kMarginDefault)
        
        self.completionButton.pin.below(of: self.completionLabel).left().right()
            .marginHorizontal(kMarginDefault).marginTop(kMarginDefault).height(kButtonHeight)
    
        self.ratingItemsButton.pin.below(of: self.completionButton).left().right()
            .marginHorizontal(kMarginDefault).marginTop(kMarginDefault).height(kButtonHeight)
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let viewHeight = kMarginDefault * 4 + kButtonHeight * 2 + kLabelHeight
        
        return CGSize(width: size.width, height: viewHeight)
    }
}

