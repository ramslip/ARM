//
//  SyncSession.swift
//  arm
//
//  Created by Victor Kalevko on 01.10.2017.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

import Alamofire
import Alamofire_Synchronous

class SyncSession: NSObject {

    let apiClient : APIClient
    let realmClient : RealmClient
    
    let login: String
    let password: String
    
    init(login: String, password: String) {
        self.login = login
        self.password = password
        
        self.apiClient = APIClient.sharedClient
        self.realmClient = RealmClient.sharedClient
    }
    
    func run(completion: @escaping (Bool) -> ()){
        
        print("[SyncSession] start")
        
        DispatchQueue.global(qos: .userInitiated).async {
         
            do{
                try self._runSync()
            }
            catch let error{
                print("[SyncSession] syncException: \(error)]")
//                throw SyncError()
        
                DispatchQueue.main.async {
                    completion(false)
                }
            }
            
            DispatchQueue.main.async {
                completion(true)
            }
        
        }
    }
    
    func _runSync() throws{
        try self.auth()
        self.syncBaseContext()
        
        for work in BaseContext.sharedContext.works {
            self.syncThemes(work: work)
        }
        
        for course in BaseContext.sharedContext.courses {
            
            self.syncRatings(course: course)
            if let packs = course.packs{
                for pack in packs{

                    self.syncPack(pack: pack)
                }
            }
            
        }
    }
    
    func auth() throws{
        
        print("[SyncSession] auth")
        let result = self.apiClient.loginSync(userName: self.login, password: self.password)
        
        if(!result){
            throw SyncError()
        }
        
        
        print("[SyncSession] auth success")
    }
    
    func syncBaseContext(){
        
        BaseContext.reset()
        
        let response = Alamofire.request(APIClient.baseUrlString + "BaseContext", method: .get).responseJSON()
        
        let json = response.result.value as! [String: AnyObject]
        
        let context = BaseContext.sharedContext
        
        context.subjects = Subject.serializeSubjects(subjectsArray: json["subjects"] as? [Dictionary<String, Any>])
        context.terms = Term.serializeTerms(termsArray: json["terms"] as? [Dictionary<String, Any>])
        context.courses = Course.serializeCourses(coursesArray:  json["courses"] as? [Dictionary<String, Any>])
        context.groups = Group.serializeGroups(groupsArray: json["groups"] as? [Dictionary<String, Any>])
        context.packs = Pack.serializePacks(packsArray: json["packs"] as? [Dictionary<String, Any>])
        context.works = Work.serializeWorks(worksArray: json["works"] as? [Dictionary<String, Any>])
        context.workStages = WorkStage.serializeWorkStages(workStagesArray: json["workStages"] as? [Dictionary<String, Any>])
        context.packToGroups = PackToGroups.serializePackToGroups(packToGroupsArray: json["packToGroups"] as? [Dictionary<String, Any>])
        context.ratingTypes = RatingType.serializeRatingTypes(ratingTypesArray: json["ratingTypes"] as? [Dictionary<String, Any>])
        
        context.students = Student.serializeStudents(studentsArray: json["students"] as? [Dictionary<String, Any>])
        
        context.studentToGroups = StudentToGroups.serializeStudentToGroups(studentToGroupsArray: json["studentToGroups"] as? [Dictionary<String, Any>])
        
        realmClient.syncBaseObjects(remoteItems: BaseContext.sharedContext.subjects)
        realmClient.syncBaseObjects(remoteItems: BaseContext.sharedContext.terms)
        realmClient.syncBaseObjects(remoteItems: BaseContext.sharedContext.courses)
        realmClient.syncBaseObjects(remoteItems: BaseContext.sharedContext.works)
        realmClient.syncBaseObjects(remoteItems: BaseContext.sharedContext.workStages)
        realmClient.syncBaseObjects(remoteItems: BaseContext.sharedContext.groups)
        realmClient.syncBaseObjects(remoteItems: BaseContext.sharedContext.students)
        realmClient.syncBaseObjects(remoteItems: BaseContext.sharedContext.studentToGroups)
        realmClient.syncBaseObjects(remoteItems: BaseContext.sharedContext.packs)
        realmClient.syncBaseObjects(remoteItems: BaseContext.sharedContext.packToGroups)
        
        realmClient.syncBaseObjects(remoteItems: BaseContext.sharedContext.ratingTypes)
        
        BaseContext.sharedContext.formCoursesWithPacks()
        Pack.addGroups()
        
        BaseContext.sharedContext.formGroupsWithStudents()
        
        print("[SyncSession] sync base context complete")
    }
    
    func syncThemes(work: Work) {
        let apiConfig = WorkProcApiURLConfig(baseApiUrl: APIClient.baseUrlString)
        let apiClient = WorkProcApiClient(apiConfig: apiConfig)
        let workThemes = try! apiClient.getWorkThemes(workId: work.id)
        if (workThemes.count > 0) {
            realmClient.syncBaseObjects(remoteItems: workThemes)
            BaseContext.sharedContext.workThemes = realmInstance.objects(WorkTheme.self).toArray()
        }
    }
    
    func syncRatings(course: Course) {
        let apiConfig = WorkProcApiURLConfig(baseApiUrl: APIClient.baseUrlString)
        let apiClient = WorkProcApiClient(apiConfig: apiConfig)
        let ratingItems = try! apiClient.getRatingItems(courseId: course.id)
        if (ratingItems.count > 0) {
            realmClient.syncBaseObjects(remoteItems: ratingItems)
            BaseContext.sharedContext.ratingItems = realmInstance.objects(RatingItem.self).toArray()
        }
    }
    
    func syncPack(pack: Pack){
        
        print("[SyncSession] sync pack \(pack.id)")
        let baseUrl = APIClient.baseUrlString
        
        let lessonSyncSession = LessonSyncSession(packId: pack.id, realmClient: self.realmClient, baseApiUrl: baseUrl)
        lessonSyncSession.run()
        
        let workProcSyncSession = WorkProcsSyncSession(packId: pack.id, realmClient: self.realmClient, baseApiUrl: baseUrl)
        workProcSyncSession.run()        
        
        print("[SyncSession] sync pack \(pack.id) complete")
    }
}
