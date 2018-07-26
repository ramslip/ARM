//
//  Lesson.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 29.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class Lesson: Object {
    
    @objc dynamic var serverId = 0
    @objc dynamic var date = Date()
    @objc dynamic var version = 0
    @objc dynamic var changed = false
    @objc dynamic var deleted = false
    @objc dynamic var packId = 0
    
    let visits = List<Visit>()
}

