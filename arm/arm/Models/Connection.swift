//
//  Connection.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 19.02.2018.
//  Copyright © 2018 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import Alamofire

class Connection: NSObject {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
