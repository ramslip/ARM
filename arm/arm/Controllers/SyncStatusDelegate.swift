//
//  SyncStatusDelegate.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 25.09.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import Foundation

 @objc protocol SyncStatusDelegate {
    @objc optional func updateStatus(status: String)
    @objc optional func allLessonsDidSync()
}
