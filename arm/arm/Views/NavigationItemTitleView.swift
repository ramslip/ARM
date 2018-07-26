//
//  NavigationItemTitleView.swift
//  arm
//
//  Created by Victor Kalevko on 04.01.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import PinLayout

class NavigationItemTitleView: UIView {
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    var subTitle: String? {
        get {
            return subtitleLabel.text
        }
        set {
            subtitleLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.font = UIFont.systemFont(ofSize: 13.0)
        subtitleLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        titleLabel.sizeToFit()
        subtitleLabel.sizeToFit()
        
        titleLabel.pin.topLeft().right().height(titleLabel.frame.size.height)
        subtitleLabel.pin.left().right().below(of: titleLabel).height(subtitleLabel.frame.size.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 40)
    }
}
