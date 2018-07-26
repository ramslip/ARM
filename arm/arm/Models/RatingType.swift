//
//  RatingType.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 23.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class RatingType: BaseObject {
    dynamic var isPositive = false
    dynamic var name = ""
    
    convenience init(id: Int, isPositive:Bool, name:String) {
        self.init()
        self.id = id
        self.isPositive = isPositive
        self.name = name
    }
    
    class func serializeRatingTypes(ratingTypesArray:[Dictionary<String, Any>]?) -> [RatingType] {
        var ratingTypesArrayToReturn = [RatingType]()
        for currentRatingType in ratingTypesArray! {
            let ratingType = RatingType(id: currentRatingType["id"] as! Int, isPositive: currentRatingType["isPositive"] as! Bool, name: currentRatingType["name"] as! String)
            ratingTypesArrayToReturn.append(ratingType)
        }
        return ratingTypesArrayToReturn
    }

}
