//
//  APIClient.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 17.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import Alamofire
import SwiftMessageBar

class APIClient: NSObject {
    static let sharedClient = APIClient()
    var delegate: SyncStatusDelegate?
    
    func login(userName: String, password: String, completionHandler: @escaping (Int?) -> Swift.Void) {
        let parameters: Parameters = ["userName": userName, "password": password]
        let urlString = APIClient.baseUrlString
        Alamofire.request(urlString + "Login", method: .post, parameters: parameters).response {
            response in
            print(response.response?.statusCode ?? 100)
            completionHandler(response.response?.statusCode ?? 100)
        }
    }
    
    func loginSync(userName: String, password: String)->Bool {
        let parameters: Parameters = ["userName": userName, "password": password]
        let response = Alamofire.request(APIClient.baseUrlString + "Login", method: .post, parameters: parameters).response()
    
        return response.response?.statusCode == 200
    }

}

