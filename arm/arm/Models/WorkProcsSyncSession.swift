//
//  WorkProcsSyncSession.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 30.10.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

import Alamofire
import Alamofire_Synchronous

class WorkProcsSyncSession: NSObject {

    let apiClient : WorkProcApiClient
    let realmClient : RealmClient
    let packId : Int
    
    init(packId: Int, realmClient: RealmClient, baseApiUrl: String) {
        self.packId = packId
        
        let apiConfig = WorkProcApiURLConfig(baseApiUrl: baseApiUrl)
        self.apiClient = WorkProcApiClient(apiConfig: apiConfig)
        self.realmClient = realmClient
    }
    
    func run() {
        let remoteWorkProcItems = try! apiClient.newWorkProcVersions(for: self.packId)
        
        let workProcsLocalArray = realmInstance
            .objects(WorkProc.self)
            .filter("packId = \(self.packId)")
        
        for remoteWorkProcItem in remoteWorkProcItems {
            //удалось сопоставить
            if let localWorkProc = workProcsLocalArray.first(where: {$0.serverId == remoteWorkProcItem.id}) {
                let workProc = try! apiClient.getFullWorkProcInfo(for: remoteWorkProcItem.id)
                self.sync(workProc: localWorkProc, with: workProc, with: localWorkProc.scheme != remoteWorkProcItem.scheme)
                realmInstance.beginWrite()
                localWorkProc.scheme = remoteWorkProcItem.scheme
                try! realmInstance.commitWrite()
                continue
            }
            else {
                //нет локальных данных о выполнении работы
                //запросить полную инфу
                let workProc = try! apiClient.getFullWorkProcInfo(for: remoteWorkProcItem.id)
                self.addWorkProc(workProcModel: workProc, update: false)
                continue
            }
            
        }
        
        for localWorkProc in workProcsLocalArray {
            if remoteWorkProcItems.first(where: {$0.id == localWorkProc.serverId}) == nil {
                // среди серверных данных отсутствует локальное занятие
                //удалить локально
            }
            
            
        }
    }
    
    func sync(workProc: WorkProc, with workProcModel: WorkProcModel, with isSchemeUpdated: Bool){
     
     realmInstance.beginWrite()
        if workProcModel.version > workProc.version {
            //обновить локальную  workProc
            workProc.version = workProcModel.version
            workProc.changed = false
            workProc.state = workProcModel.state
            workProc.startDate = workProcModel.startDate
            if workProcModel.endDate != nil {
                workProc.endDate = Utils.dateWith(string: workProcModel.endDate!)!
            }
        } else {
            if (workProc.changed) {
                let newVersion = try! apiClient.newWorkProcVersionsPost(for: workProc)
                workProc.version = newVersion
                workProc.changed = false
                
            }
        }
        
        let remoteStudentWorkProcInfo = try! apiClient.getNewStudentWorkProcInfo(for: workProcModel.id)
        for remoteStudentWorkProcItem in remoteStudentWorkProcInfo {
            if let localStudentWorkProc = realmInstance.objects(StudentWorkProc.self).filter({$0.id == remoteStudentWorkProcItem.id}).first {
                if (isSchemeUpdated) {
                      /*Если удалось найти, но была изменена схема, то также нужно запросить полную информацию и на её основе обновить локальную запись (в т. ч. добавить или удалить ВыполненияЭтаповРаботы)*/
                    let newStudentWorkProc = try! apiClient.getNewStudentWorkProcCommit(for: localStudentWorkProc.id)
                    localStudentWorkProc.version = newStudentWorkProc.version
                    localStudentWorkProc.completion = newStudentWorkProc.completion!
                    localStudentWorkProc.completionDate = newStudentWorkProc.completionDate == nil ? "" : newStudentWorkProc.completionDate!
                    localStudentWorkProc.changed = false
                    for newStudentStageProc in newStudentWorkProc.studentStageProcs {
                        var localStageProc = realmInstance.objects(StudentStageProc.self).toArray().filter({$0.id == newStudentStageProc.stageId}).first
                        if (localStageProc == nil) {
                            localStageProc = StudentStageProc()
                            localStageProc?.changed = false
                            localStageProc?.completed = newStudentStageProc.completed
                            if (newStudentStageProc.completionDate != nil) {
                                localStageProc?.completionDate = newStudentStageProc.completionDate!
                            }
                            localStageProc?.studentWorkProcId = newStudentWorkProc.id
                            localStageProc?.version = newStudentStageProc.version
                            localStageProc?.id = newStudentStageProc.id
                            localStageProc?.workStageId = newStudentStageProc.stageId
                            realmInstance.add(localStageProc!, update:true)
                            localStudentWorkProc.studentStageProcs.append(localStageProc!)
                        } else {
                            localStageProc?.completed = newStudentStageProc.completed
                            localStageProc?.changed = false
                            localStageProc?.completionDate = newStudentStageProc.completionDate == nil ? "" : newStudentStageProc.completionDate!
                            localStageProc?.version = newStudentStageProc.version
                        }
                    }
                }
                if (remoteStudentWorkProcItem.version > localStudentWorkProc.version) {
                    /* Если серверная версия выше, то так же нужно запросить полную информацию и обновить локальную запись.*/
                    let newStudentWorkProc = try! apiClient.getNewStudentWorkProcCommit(for: localStudentWorkProc.id)
                    localStudentWorkProc.version = newStudentWorkProc.version
                    localStudentWorkProc.completion = newStudentWorkProc.completion!
                    localStudentWorkProc.completionDate = newStudentWorkProc.completionDate == nil ? "" : newStudentWorkProc.completionDate!
                    localStudentWorkProc.changed = false
                    for newStudentStageProc in newStudentWorkProc.studentStageProcs {
                        let localStageProc = localStudentWorkProc.studentStageProcs.filter({ $0.id == newStudentStageProc.id }).first
                        localStageProc?.completed = newStudentStageProc.completed
                        localStageProc?.changed = false
                        localStageProc?.completionDate = newStudentStageProc.completionDate == nil ? "" : newStudentStageProc.completionDate!
                        localStageProc?.version = newStudentStageProc.version
                    }

                }
                else {
                    /*Если версии равны и присутствуют изменения (флаг changed у выполненияРаботСтудента и выполненииЭтаповРаботы), то нужно оправить изменения на сервер (/NewStudentWorkProcCommit
                     ) и обработать полученный ответ, т.е. обновить версии выполненияРаботСтудента и выполненииЭтаповРаботы, сбросить флаг changed
                     */
                    if (localStudentWorkProc.changed) {
                        let updateResult = try! apiClient.newStudentWorkProcCommit(for: localStudentWorkProc)
                        localStudentWorkProc.version = updateResult.newVersion
                        
                        for pair in updateResult.stageVersions {
                            let stageProc = localStudentWorkProc.studentStageProcs.first(where: {$0.id == pair.key})!
                            stageProc.version = pair.value
                            stageProc.changed = false
                        }
                        
                        localStudentWorkProc.changed = false
                    }
                    for localStudentStageProc in localStudentWorkProc.studentStageProcs {
                        if localStudentStageProc.changed {
                            let updateResult = try! apiClient.newStudentWorkProcCommit(for: localStudentWorkProc)
                            localStudentWorkProc.version = updateResult.newVersion
                            
                            for pair in updateResult.stageVersions {
                                let stageProc = localStudentWorkProc.studentStageProcs.first(where: {$0.id == pair.key})!
                                stageProc.version = pair.value
                                stageProc.changed = false
                            }
                            
                            localStudentStageProc.changed = false
                        }
                    }
                }
            }
            else {
                /*Если не удалось найти локальную информацию о выполненияРаботыСтудента, значит студент был переведен в группу после последней синхронизации и нужно запросить полную информацию по его работе /NewStudentWorkProcCommit и на её основе создать локальную запись.*/
            }
        }
     
     try! realmInstance.commitWrite()
     
     }
    
    func addWorkProc(workProcModel: WorkProcModel, update: Bool) {
        let workProc = WorkProc()
        if workProcModel.endDate != nil {
            workProc.endDate = Utils.dateWith(string: workProcModel.endDate!)!
        }
        workProc.workId = workProcModel.workId
        workProc.startDate = workProcModel.startDate
        workProc.serverId = workProcModel.id
        workProc.state = workProcModel.state
        workProc.version = workProcModel.version
        workProc.scheme = workProcModel.scheme
        workProc.packId = self.packId
        
        for studentWorkProcModel in workProcModel.studentWorkProcs {
            let studentWorkProc = StudentWorkProc()
            studentWorkProc.workThemeId = studentWorkProcModel.workThemeId == nil ? 0 : studentWorkProcModel.workThemeId!
            studentWorkProc.studentId = studentWorkProcModel.studentId!
            studentWorkProc.completionDate = studentWorkProcModel.completionDate == nil ? "" : studentWorkProcModel.completionDate!
            studentWorkProc.version = studentWorkProcModel.version
            studentWorkProc.completion = studentWorkProcModel.completion!
            studentWorkProc.id = studentWorkProcModel.id
            for studentStageProcModel in studentWorkProcModel.studentStageProcs {
                let studentStageProc = StudentStageProc()
                studentStageProc.id = studentStageProcModel.id
                studentStageProc.workStageId = studentStageProcModel.stageId
                studentStageProc.studentWorkProcId = studentWorkProcModel.id
                studentStageProc.version = studentStageProcModel.version
                studentStageProc.completed = studentStageProcModel.completed
                studentStageProc.completionDate = studentStageProcModel.completionDate == nil ? "" : studentStageProcModel.completionDate!
                studentWorkProc.studentStageProcs.append(studentStageProc)
            }
            workProc.studentWorkProcs.append(studentWorkProc)
        }
        BaseContext.sharedContext.workProcs.append(workProc)
        try! realmInstance.write {
            NSLog("[WorkProcSync] add workProc for pack \(workProc.packId) with serverId \(workProc.serverId) and \(workProc.studentWorkProcs.count) studentWorkProcs")
            realmInstance.add(workProc, update: update)
        }
    }
}


