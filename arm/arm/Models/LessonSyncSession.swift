//
//  LessonSyncSession.swift
//  arm
//
//  Created by Victor Kalevko on 03.10.2017.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit


import Alamofire
import Alamofire_Synchronous

class LessonSyncSession: NSObject {

    let apiClient : LessonApiClient
    let realmClient : RealmClient
    let packId : Int
    
    init(packId: Int, realmClient: RealmClient, baseApiUrl: String) {
        self.packId = packId
        
        let apiConfig = LessonApiURLConfig(baseApiUrl: baseApiUrl)
        self.apiClient = LessonApiClient(apiConfig: apiConfig)
        self.realmClient = realmClient
    }
    
    func run() {
        
        let remoteLessonItems = try! apiClient.getLessonDates(for: self.packId)
        
        let lessonsLocalArray = realmInstance
            .objects(Lesson.self)
            .filter("packId = \(self.packId)")
        
        for remoteLessonItem in remoteLessonItems {
            
            //удалось сопоставить
            if let localLesson = lessonsLocalArray.first(where: {$0.date == remoteLessonItem.lessonDate}){
                
                if localLesson.deleted == true {
                    
                    let result = try! self.apiClient.deleteLesson(serverLessonId: localLesson.serverId)
                    
                    //удалить локально
                    if result {
                        self.deleteLesson(lesson: localLesson)
                    }
                    continue
                }
                
                if remoteLessonItem.version > localLesson.version {
                    //запросить полную инфу о занятии
                    //обновить
                    let lessonModel = try! apiClient.getFullLessonInfo(for: remoteLessonItem.serverLessonId)
                    self.sync(lesson: localLesson, with: lessonModel)
                    continue
                }
                    
                if lessonHasChanges(lesson: localLesson) {
                    //отправить изменения, тут с visit
                    
                    let lessonChangedData = localLesson.toUpdateLessonData()
                    
                    NSLog("[LessonSync] update lesson with date \(lessonChangedData.lessonDate) and \(lessonChangedData.visits.count) visits")
                    
                    let updatedData = try! self.apiClient.updateLesson(updateLesonData: lessonChangedData)
                    self.sync(lesson: localLesson, with: updatedData)
                }
            }
            else{
                
                //нет локальных данных о занятии
                //запросить полную инфу о занятии
                //сохранить
                
                let lesson = try! apiClient.getFullLessonInfo(for: remoteLessonItem.serverLessonId)
                self.addLesson(lessonModel: lesson)
                continue
                
            }
        }
        
        for localLesson in lessonsLocalArray {
            if remoteLessonItems.first(where: {$0.lessonDate == localLesson.date}) == nil {
                // среди серверных данных отсутствует локальное занятие
                if localLesson.serverId > 0 {
                    self.deleteLesson(lesson: localLesson)
                }
                else {
                    //создать на сервере
                    let lessonCreateData = localLesson.toNewLessonData()
                    let updatedLesson = try! self.apiClient.createLesson(createLessonData: lessonCreateData)
                    self.sync(lesson: localLesson, with: updatedLesson)
                }
            }
        }

    }
    
    func addLesson(lessonModel: LessonModel){
        
        let lesson = Lesson()
        lesson.date = lessonModel.lessonDate
        lesson.serverId = lessonModel.serverId
        lesson.packId = lessonModel.packId
        lesson.version = lessonModel.version
        
        for visitModel in lessonModel.visits {
            let visit = Visit()
            visit.studentId = visitModel.studentId
            visit.value = visitModel.value
            visit.version = visitModel.version
            
            lesson.visits.append(visit)
        }
        
        try! realmInstance.write {
            NSLog("[LessonSync] add lesson for pack \(lesson.packId) with date \(lesson.date) and \(lesson.visits.count) visits")
            realmInstance.add(lesson, update: false)
        }
    }
    
    func lessonHasChanges(lesson: Lesson) -> Bool{
        if lesson.changed {
            return true
        }
        
        for visit in lesson.visits {
            if visit.changed {
                return true
            }
        }
        
        return false
    }
    
    
    func sync(lesson: Lesson, with updateData: UpdateLessonResponseData){
        
        
        realmInstance.beginWrite()
        
        lesson.changed = false
        lesson.version = updateData.newVersion
        
        for visitModel in updateData.visits {
            
            if let lessonVisit = lesson.visits.first(where: {$0.studentId == visitModel.studentId}){
                lessonVisit.value = visitModel.value
                lessonVisit.version = visitModel.version
                lessonVisit.changed = false
            }
            else{
                //TODO добавить визит
            }
        }
        
        try! realmInstance.commitWrite()
    }
    
    func sync(lesson: Lesson, with lessonModel: LessonModel){
        
        realmInstance.beginWrite()
        
        lesson.changed = false
        lesson.serverId = lessonModel.serverId
        lesson.version = lessonModel.version
        
        for visitModel in lessonModel.visits {
            
            if let lessonVisit = lesson.visits.first(where: {$0.studentId == visitModel.studentId}){
                lessonVisit.value = visitModel.value
                lessonVisit.version = visitModel.version
                lessonVisit.changed = false
            }
            else{
                //TODO добавить визит
            }
        }
        
        try! realmInstance.commitWrite()

//        realmClient.save(lesson: lesson)
    }
    
    func deleteLesson(lesson: Lesson){
        
        try! realmInstance.write {
            realmInstance.delete(lesson)
        }
    }
}

extension Lesson {
    
    func toUpdateLessonData() -> LessonModel {
        let changedVisits = self.visits.filter({ $0.changed})
            .map{VisitModel(studentId: $0.studentId, value: $0.value, version: $0.version)}
        
        let visitsArray = [VisitModel](changedVisits)
        
        let lessonModel = LessonModel(serverId: self.serverId,
                                      packId: self.packId,
                                      version: self.version,
                                      lessonDate: self.date,
                                      visits: visitsArray)
        return lessonModel
    }
    
    func toNewLessonData() -> LessonModel{
        let visits = self.visits
            .map{VisitModel(studentId: $0.studentId, value: $0.value, version: $0.version)}
        
        let visitsArray = [VisitModel](visits)
        
        let lessonModel = LessonModel(serverId: self.serverId,
                                      packId: self.packId,
                                      version: self.version,
                                      lessonDate: self.date,
                                      visits: visitsArray)
        return lessonModel
    }
}
