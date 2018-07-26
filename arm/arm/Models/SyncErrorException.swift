//
//  SyncErrorException.swift
//  arm
//
//  Created by Victor Kalevko on 03.10.2017.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

class SyncError: Error {

}

class HttpError: Error {
    
}

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}
