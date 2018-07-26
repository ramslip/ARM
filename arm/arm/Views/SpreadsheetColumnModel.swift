//
//  ColumnModel.swift
//  arm
//
//  Created by Victor Kalevko on 04.01.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import SpreadsheetView

protocol SpreadsheetColumnModel {
    
    var numberOfRows: Int { get }
    
    func heightForHeader() -> CGFloat
    
    func heightFor(row: Int) -> CGFloat
    
    func widthForColumn() -> CGFloat
    
    func cellForHeader(spreadsheetView: SpreadsheetView) -> Cell
    
    func cellFor(row: Int, spreadsheetView: SpreadsheetView) -> Cell
}

class SimpleSpreadsheetColumnModel: SpreadsheetColumnModel {
    
    private let headerTitle: String
    private let rowTitles: [String]
    private let textAlignment: NSTextAlignment
    
    private let minColumnWidth: CGFloat
    private let maxColumnWidth: CGFloat
    
    private var columnWidth: CGFloat = 0
    
    init(headerTitle: String, rowTitles: [String], textAlignment: NSTextAlignment = .left, minColumnWidth: CGFloat = 30, maxColumnWidth: CGFloat = 150) {
        self.headerTitle = headerTitle
        self.rowTitles = rowTitles
        self.textAlignment = textAlignment
        self.minColumnWidth = minColumnWidth
        self.maxColumnWidth = maxColumnWidth
        
        self.columnWidth = calculateMaxWidth() + 16 // padding * 2
    }
    
    var numberOfRows: Int {
        return rowTitles.count
    }
    
    func heightForHeader() -> CGFloat {
        return 50
    }
    
    func heightFor(row: Int) -> CGFloat {
        return 50
    }
    
    func widthForColumn() -> CGFloat {
        return columnWidth
    }
    
    private func calculateMaxWidth() -> CGFloat {
        var nameSizes = [CGFloat]()
        for title in rowTitles {
            let size: CGSize = title.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17.0)])
            nameSizes.append(size.width)
        }
        
        let calcMaxWidth = (nameSizes.max{ $0 < $1 })!
        
        return calcMaxWidth < minColumnWidth ? minColumnWidth : calcMaxWidth
    }
    
    func cellForHeader(spreadsheetView: SpreadsheetView) -> Cell {
        let cell: PackCollectionViewCell = spreadsheetView.dequeueReusableCell()
        cell.configGridlines()
        cell.textLabel.text = self.headerTitle
        cell.textLabel.textAlignment = self.textAlignment
        return cell
    }
    
    func cellFor(row: Int, spreadsheetView: SpreadsheetView) -> Cell {
        let cell: PackCollectionViewCell = spreadsheetView.dequeueReusableCell()
        cell.configGridlines()
        cell.textLabel.text = self.rowTitles[row]
        cell.textLabel.textAlignment = self.textAlignment
        return cell
    }
}

class EmptyColumnModel: SpreadsheetColumnModel {
    
    var numberOfRows: Int
    
    init(rowsCount: Int) {
        self.numberOfRows = rowsCount
    }
    
    func heightForHeader() -> CGFloat {
        return 50
    }
    
    func heightFor(row: Int) -> CGFloat {
        return 50
    }
    
    func widthForColumn() -> CGFloat {
        return 50
    }
    
    func cellForHeader(spreadsheetView: SpreadsheetView) -> Cell {
        let cell: PackCollectionViewCell = spreadsheetView.dequeueReusableCell()
        cell.configGridlines()
        cell.textLabel.text = nil
        return cell
    }
    
    func cellFor(row: Int, spreadsheetView: SpreadsheetView) -> Cell {
        let cell: PackCollectionViewCell = spreadsheetView.dequeueReusableCell()
        cell.configGridlines()
        cell.textLabel.text = nil
        return cell
    }
}

