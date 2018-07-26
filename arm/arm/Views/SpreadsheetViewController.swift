//
//  SpreadSheetViewController.swift
//  arm
//
//  Created by Victor Kalevko on 04.01.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import SpreadsheetView

protocol SpreadsheetViewController: SpreadsheetViewDataSource, SpreadsheetViewDelegate { }

extension Cell: ReusableView {}

extension Cell {
    func configGridlines(with color: UIColor = .black) {
        self.gridlines.top = .solid(width:1, color: color)
        self.gridlines.left = .solid(width:1, color: color)
        self.gridlines.bottom = .solid(width:1, color: color)
        self.gridlines.right = .solid(width:1, color: color)
    }
}

extension SpreadsheetView {
    
    func register<T: Cell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func register<T: Cell>(_: T.Type) where T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: Cell>(forIndexPath indexPath: NSIndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath as IndexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
    
    func dequeueReusableCell<T: Cell>() -> T {
        //внутри SpreadsheetView indexPath не используется
        return dequeueReusableCell(forIndexPath: NSIndexPath(row: 0, section: 0))
    }
}

