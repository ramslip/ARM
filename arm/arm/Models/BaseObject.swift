//
//  BaseObject.swift
//  arm
//
//  Created by Victor Kalevko on 01.10.2017.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class BaseObject: Object {

    dynamic var id = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}


