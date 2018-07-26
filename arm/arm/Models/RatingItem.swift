//
//  RatingItem.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 31.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class RatingItem: BaseObject {
    dynamic var courseId = 0
    dynamic var studentId = 0
    dynamic var typeId = 0
    dynamic var comment = ""
    dynamic var date = Date()
    dynamic var value = 0
    dynamic var serverId = 0
    dynamic var deleted = false

    convenience init(id: Int, courseId:Int, studentId:Int, typeId: Int, comment: String, date: String, value: Int, serverId: Int, deleted: Bool) {
        self.init()
        self.date = Utils.dateWith(string: date)!
        self.id = id
        self.courseId = courseId
        self.studentId = studentId
        self.typeId = typeId
        self.comment = comment
        self.value = value
        self.serverId = serverId
        self.deleted = deleted
    }

    class func serializeRatingItems(ratingItemsArray:[Dictionary<String, Any>]?) -> [RatingItem] {
        var ratingItemArrayToReturn = [RatingItem]()
        for currentRatingItem in ratingItemsArray! {
            let value = currentRatingItem["value"] as? Int ?? Int(currentRatingItem["value"] as? String ?? "")
            let comment = currentRatingItem["comment"]  as? String ?? ""
            let ratingItem = RatingItem(id: currentRatingItem["id"] as! Int,
                                        courseId: currentRatingItem["courseId"] as! Int,
                                        studentId: currentRatingItem["studentId"] as! Int,
                                        typeId: currentRatingItem["typeId"] as! Int,
                                        comment: comment,
                                        date: currentRatingItem["date"] as! String,
                                        value: value!, serverId: currentRatingItem["id"] as! Int,
                                        deleted: false)
            ratingItemArrayToReturn.append(ratingItem)
        }
        return ratingItemArrayToReturn
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return ["comment" : self.comment,
                "date" : dateFormatter.string(from: self.date),
                "value" : self.value,
                "courseId" : self.courseId,
                "typeId" : self.typeId,
                "localId" : self.id,
                "studentId" : self.studentId,
                "id" : self.serverId,
                "deleted" : self.deleted]
    }
    
    class func ratingIdsToString(ratingItems: [RatingItem]) -> [Int] {
        var stringsArray = [Int]()
        for rating in ratingItems {
            stringsArray.append(rating.serverId)
        }
        return stringsArray
    }
    
    class func serializeIds(Ids: [Int]) -> [Int] {
        var idsArray = [Int]()
        for (id) in Ids {
            idsArray.append(id)
        }
        return idsArray
    }

}
