//
//  RealmClient.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 18.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftMessageBar


class RealmClient: NSObject {
    static let sharedClient = RealmClient()

    enum CompareParameter: Int {
        case subject = 0
        case term = 1
    }
    
    func syncBaseObjects<T>(remoteItems: [T]) {
        print("[ReamlClient] syncBaseObjects not implemented for \(T.self)")
    }
    
    func syncBaseObjects<T: BaseObject>(remoteItems: [T]) {
        
        let localItems = realmInstance.objects(T.self).toArray()
        let termsServerArrayMutable = remoteItems.sorted() { $0.id > $1.id }
        dump(termsServerArrayMutable)
        for serverRecord in termsServerArrayMutable {
            try! realmInstance.write {                
//                print("[ReamlClient] updateRecord: \(serverRecord)")
                realmInstance.add(serverRecord, update: true)
            }
        }
        
        for localRecord in localItems {
            if termsServerArrayMutable.first(where: {$0.id == localRecord.id}) == nil {
                try! realmInstance.write {
                    realmInstance.delete(localRecord)
                }
            }
        }
        
    }
    
    func syncBaseObjects<T: WorkTheme>(remoteItems: [T]) {
        let workThemesLocalArray = realmInstance.objects(WorkTheme.self).sorted() { $0.serverId > $1.serverId }
        let workThemesServerArrayMutable = remoteItems.sorted() { $0.serverId > $1.serverId }
        
        for serverTheme in workThemesServerArrayMutable {
            if workThemesLocalArray.first(where: {$0.serverId == serverTheme.serverId}) != nil {
                try! realmInstance.write {
                    realmInstance.add(serverTheme, update: true)
                }
            }
            else {
                try! realmInstance.write {
                    realmInstance.add(serverTheme, update: false)
                }
            }
        }
        
        /*Выбрать локальные темы, которые не зарегистрированы на сервере (serverId == 0) и зарегистрировать на сервере, обновить serverId в соответствии с ответом
         Найти ВыполненияРаботыСтудентами для которых localThemeId != 0; сбросить localThemeId в 0 и  установить значение workThemeId = serverId*/

    }
    
    func syncBaseObjects<T: RatingItem>(remoteItems: [T]) {
        let ratingLocalArray = realmInstance.objects(RatingItem.self).sorted() { $0.serverId > $1.serverId }
        let ratingServerArrayMutable = remoteItems.sorted() { $0.serverId > $1.serverId }
        
        for serverRating in ratingServerArrayMutable {
            let localRating = ratingLocalArray.first(where: {$0.serverId == serverRating.serverId})
            if localRating != nil  {
                if (localRating?.deleted == true) {
                    continue
                }
                try! realmInstance.write {
                    realmInstance.add(serverRating, update: true)
                }
            }
            else {
                try! realmInstance.write {
                    realmInstance.add(serverRating, update: false)
                }
            }
        }
        
        var localRatingsToDelete = [RatingItem]()
        let apiConfig = WorkProcApiURLConfig(baseApiUrl: APIClient.baseUrlString)
        let apiClient = WorkProcApiClient(apiConfig: apiConfig)
        for localRating in ratingLocalArray {
            if (localRating.deleted) {
                localRatingsToDelete.append(localRating)
            }
            if (localRating.serverId == 0) {
                let registeredRating = try! apiClient.commitRatingItem(ratingItem: localRating)
                print("[RealmClient] register local rating \(localRating) with id \(registeredRating.serverId)")
                localRating.serverId = registeredRating.serverId
                try! realmInstance.write {
                    realmInstance.add(localRating, update: true)
                }
            }
        }
        if (localRatingsToDelete.count > 0) {
            print("[RealmClient] request localRatingsToDelete: \(localRatingsToDelete)")
            let idsToDelete = try! apiClient.deleteRatings(ratingItems: localRatingsToDelete)
            print("[RealmClient] confirm idsToDelete: \(idsToDelete)")
            realmInstance.beginWrite()
            for idToDelete in idsToDelete {
                realmInstance.delete(realmInstance.objects(RatingItem.self).filter({$0.id == idToDelete}).first!)
            }
            try! realmInstance.commitWrite()
        }
    }
    
    func syncBaseObjects<T: PackToGroups>(remoteItems: [T]) {
 
        let packToGroupsLocalArray = realmInstance.objects(PackToGroups.self).sorted() { $0.groupId > $1.groupId }
        let packToGroupsServerArrayMutable = remoteItems.sorted() { $0.groupId > $1.groupId }

        for serverRecord in packToGroupsServerArrayMutable {
            
            let localRecord = packToGroupsLocalArray.first(where: {$0.packId == serverRecord.packId && $0.groupId == serverRecord.groupId})
            
            if localRecord == nil {
                
                try! realmInstance.write {
                    realmInstance.add(serverRecord, update: false)
                }
            }
        }
        
        
        for localRecord in packToGroupsLocalArray {
            if packToGroupsServerArrayMutable.first(where: {$0.packId == localRecord.packId
                && $0.groupId == localRecord.groupId}) == nil {
                try! realmInstance.write {
                    realmInstance.delete(localRecord)
                }
            }
        }
    }
    
    
    func syncBaseObjects<T: StudentToGroups>(remoteItems: [T]) {
        let studentToGroupsLocalArray = realmInstance.objects(StudentToGroups.self).sorted() { $0.groupId > $1.groupId }
        let studentToGroupsServerArrayMutable = remoteItems.sorted() { $0.groupId > $1.groupId }
        
        for serverRecord in studentToGroupsServerArrayMutable {
            
            let localRecord = studentToGroupsLocalArray.first(where: {$0.studentId == serverRecord.studentId && $0.groupId == serverRecord.groupId})
            
            if localRecord == nil {
            
                try! realmInstance.write {
                    realmInstance.add(serverRecord, update: false)
                }
            }
        }
        
        for localRecord in studentToGroupsLocalArray {
            if studentToGroupsServerArrayMutable.first(where: {$0.studentId == localRecord.studentId
                && $0.groupId == localRecord.groupId}) == nil {
                try! realmInstance.write {
                    realmInstance.delete(localRecord)
                }
            }
        }
    }
    
    func compareRatingItems(ratingItemsServerArray: [RatingItem]) {
        let ratingItemsLocalArray = realmInstance.objects(RatingItem.self).sorted() { $0.id > $1.id }
        let ratingItemsServerArrayMutable = ratingItemsServerArray.sorted() { $0.id > $1.id }
        for serverRecord in ratingItemsServerArrayMutable {
            if ratingItemsLocalArray.index(where: { $0.id == serverRecord.id }) == nil {
                //сохранить бонус локально
                try! realmInstance.write {
                    realmInstance.add(serverRecord, update: false)
                }
            }
            else {
                //обновить
                try! realmInstance.write {
                    realmInstance.add(serverRecord, update: true)
                }
            }
        }
        
        let notRegisteredRatingItems = ratingItemsLocalArray.filter( { $0.serverId == 0 } )
        if notRegisteredRatingItems.count > 0 {
            //зарегать на сервере
            //обновить серверные айди в соответствии с ответом
        }
        //deleted?
    }
    
    func createLesson(lessonDate: Date, packId: Int, visits: [Visit]) -> (Lesson){
//        let lesson = Lesson(id: Lesson.incrementId(), date: lessonDate, packId: packId)
        
        let lesson = Lesson()
        lesson.date = lessonDate
        lesson.packId = packId
        
        for visit in visits {
            lesson.visits.append(visit)
        }
        
        try! realmInstance.write {
            realmInstance.add(lesson, update: false)
        }
//        for visit in visits {
//            let newVisit = Visit(id: Visit.incrementId(), lessonId: lesson.id, studentId: visit.studentId, changed: false, value: visit.value, version: 0)
//            lesson.visits.append(newVisit)
//            try! realmInstance.write {
//                realmInstance.add(newVisit, update: false)
//            }
//        }
        return lesson
    }
    
    func deleteObject(object: Object){
        realmInstance.delete(object)
    }
    
    func save(lesson: Lesson){
        realmInstance.add(lesson, update: true)
    }
    
    func updateVisits(visits: [Visit], lesson: Lesson) {
//        let lessonToUpdate = realmInstance.object(ofType: Lesson.self, forPrimaryKey: lessonId)
//        let lesson = Lesson(id: lessonId, date: (lessonToUpdate?.date)!, packId: (lessonToUpdate?.packId)!)
//        lesson.serverId = (lessonToUpdate?.serverId)!
//        lesson.version = (lessonToUpdate?.version)!
//        lesson.changed = true
//        lesson.deleted = (lessonToUpdate?.deleted)!
//        try! realmInstance.write {
//            realmInstance.add(lesson, update: true)
//        }
        
//        for visit in visits {
//            try! realmInstance.write {
//                realmInstance.add(visit, update: true)
//            }
//        }

        try! realmInstance.write {
            lesson.changed = true
            
            for changedVisit in visits {
                if let visit = lesson.visits.first(where: {$0.studentId == changedVisit.studentId}){
                    visit.valueEnum = changedVisit.valueEnum
                    visit.changed = true
                }
            }
        }
    
    }

    func markLessonAsDeleted(lesson: Lesson) {
//        let lessonToDelete = Lesson(id: lesson.id, date: lesson.date, packId: lesson.packId)
//        lessonToDelete.version = lesson.version
//        lessonToDelete.serverId = lesson.serverId
//        lessonToDelete.changed = lesson.changed
        
        
        guard let targetLesson = realmInstance.objects(Lesson.self).first(where: {$0.date == lesson.date}) else {
            NSLog("unable to mark lesson as deleted!")
            return
        }
        
        try! realmInstance.write {
            targetLesson.deleted = true
        }
    }

    func start(workProc: WorkProc, with endDate: Date?){
        
        try! realmInstance.write {
            workProc.startDate = Date()
            workProc.endDate = endDate
            workProc.changed = true
            workProc.state = 0
        }
    }
}
extension Results {
    
    func toArray() -> [Element] {
        var array = [Element]()
        for result in self {
            array.append(result)
        }
        return array
    }
}
