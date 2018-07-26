//
//  PackCollectionViewCell.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 23.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import SpreadsheetView
import PinLayout

class PackCollectionViewCell: Cell {

    var textLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.textLabel.textColor = UIColor.black
        self.textLabel.text = ""
        self.backgroundColor = UIColor.white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.pin.all().margin(8)
    }
}

class HeaderWithSubtitleCell: Cell {
    
    let textLabel = UILabel()
    let subtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(textLabel)
        self.contentView.addSubview(subtitleLabel)
    
        textLabel.textColor = .black
        textLabel.font = UIFont.systemFont(ofSize: 15)
        
        subtitleLabel.textColor = .gray
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.pin.topLeft().right().margin(8).height(20)
        subtitleLabel.pin.left().below(of: textLabel).right().marginTop(0).marginHorizontal(8).marginBottom(8).height(17)
    }
}

class PackWorkProgressViewCell : PackCollectionViewCell {
    
    let greenView: UIView = UIView()
    
    override init(frame: CGRect) {
        self.progress = 0
        super.init(frame: frame)
        self.contentView.insertSubview(greenView, at: 0)
        self.greenView.backgroundColor = ColorsHelper.green()
        self.textLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var progress : Float {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let widthPercent = (CGFloat(progress * 100))%
        self.greenView.pin.topLeft().bottom().width(widthPercent)
    }
}

class PackWorkWithThemeProgressViewCell : PackWorkProgressViewCell{
    
    let themeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        themeLabel.font = UIFont.systemFont(ofSize: 12)
        themeLabel.textColor = .gray
        self.contentView.addSubview(themeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let widthPercent = (CGFloat(progress * 50))%
        
        themeLabel.pin.topLeft().bottom().width(50%).margin(8)
        greenView.pin.top().bottom().right(of: themeLabel).width(widthPercent)
        
        textLabel.pin.top().bottom().right(of: themeLabel).margin(8)
    }
}
