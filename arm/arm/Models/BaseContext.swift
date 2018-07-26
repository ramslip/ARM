//
//  BaseContext.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 21.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit
import RealmSwift

class BaseContext: NSObject {
    static private (set) var sharedContext = BaseContext()

    var subjects: [Subject]
    var terms: [Term]
    var courses: [Course]
    var groups: [Group]
    var packs: [Pack]
    var packToGroups: [PackToGroups]
    var ratingTypes: [RatingType]
    var students: [Student]
    var studentToGroups: [StudentToGroups]
    var lessons: [Lesson]
    var ratingItems: [RatingItem]
    var works: [Work]
    var workStages: [WorkStage]
    var workProcs: [WorkProc]
    var workThemes: [WorkTheme]
    
    var lessonsDates: [Lesson] = []
    var packsInCourses: [Course]
    
    override init() {
        self.subjects = []
        self.terms = []
        self.courses = []
        self.groups = []
        self.packs = []
        self.packToGroups = []
        self.ratingTypes = []
        self.students = []
        self.studentToGroups = []
        self.lessons = []
        self.ratingItems = []
        self.works = []
        self.workStages = []
        self.workProcs = []
        self.packsInCourses = []
        self.workThemes = []
    }
    
    func reset() {
        self.subjects = []
        self.terms = []
        self.courses = []
        self.groups = []
        self.packs = []
        self.packToGroups = []
        self.ratingTypes = []
        self.students = []
        self.studentToGroups = []
        self.lessons = []
        self.ratingItems = []
        self.lessonsDates = []
        self.packsInCourses = []
        self.works = []
        self.workStages = []
        self.workProcs = []
        self.workThemes = []
    }
    
    func initWithBase() {
        self.workThemes = realmInstance.objects(WorkTheme.self).toArray()
        self.subjects = realmInstance.objects(Subject.self).toArray()/*.reversed()*/
        self.terms = realmInstance.objects(Term.self).toArray()/*.reversed()*/
        self.courses = realmInstance.objects(Course.self).toArray()/*.reversed()*/
        self.groups = realmInstance.objects(Group.self).toArray()/*.reversed()*/
        self.packs = realmInstance.objects(Pack.self).toArray()/*.reversed()*/
        self.formCoursesWithPacks()
        self.students = realmInstance.objects(Student.self).toArray()/*.reversed()*/
        self.packToGroups = realmInstance.objects(PackToGroups.self).toArray()/*.reversed()*/
        self.ratingTypes = realmInstance.objects(RatingType.self).toArray()/*.reversed()*/
        self.ratingItems = realmInstance.objects(RatingItem.self).toArray()/*.reversed()*/
        self.lessons = realmInstance.objects(Lesson.self).toArray()/*.reversed()*/
        self.studentToGroups = realmInstance.objects(StudentToGroups.self).toArray()/*.reversed()*/
        self.works = realmInstance.objects(Work.self).toArray()/*.reversed()*/
        self.workStages = realmInstance.objects(WorkStage.self).toArray()/*.reversed()*/
        self.workProcs = realmInstance.objects(WorkProc.self).toArray()/*.reversed()*/
        self.formGroupsWithStudents()
        Pack.addGroups()
//        Lesson.addVisits()
    }
    
    func formCoursesWithPacks() {
        
        self.packsInCourses = []
        
//        print("courses: \(self.courses)")
//        print("packs: \(self.packs)")
        
        for course in self.courses {
            let packsForCourse = self.packs.filter{$0.courseId == course.id}
            course.packs = packsForCourse
            self.packsInCourses.append(course)
        }
    }
    
    func formGroupsWithStudents() {
        for group in self.groups {
            group.students = []
            let studentToGroups = self.studentToGroups.filter({
                $0.groupId == group.id
            })
            
            group.students = []
            
            for record in studentToGroups {
                let student = self.students.filter{ $0.id == record.studentId }.first
                group.students?.append(student!)
            }
            group.students?.sort{ $0.surname < $1.surname }
        }
        
//        print("groups: \(self.groups)")
    }
    
//    func formLessonsWithVisits(){
//        for lesson in self.lessons {
//            lesson.visits = realmInstance.objects(Visit.self).filter("lessonId = \(lesson.id)").toArray()
//        }
//    }
    
    class func reset(){
        self.sharedContext = BaseContext()
        
        realmInstance = try! Realm()
        
        self.sharedContext.courses = realmInstance.objects(Course.self).toArray()
        
        self.sharedContext.subjects = realmInstance.allObjectsAsArray()
        self.sharedContext.terms = realmInstance.allObjectsAsArray()
        self.sharedContext.courses = realmInstance.allObjectsAsArray()
        self.sharedContext.groups = realmInstance.allObjectsAsArray()
        self.sharedContext.packs = realmInstance.allObjectsAsArray()
        self.sharedContext.packToGroups = realmInstance.allObjectsAsArray()
        self.sharedContext.ratingTypes = realmInstance.allObjectsAsArray()
        self.sharedContext.students = realmInstance.allObjectsAsArray()
        self.sharedContext.studentToGroups = realmInstance.allObjectsAsArray()
        self.sharedContext.ratingItems = realmInstance.allObjectsAsArray()
        self.sharedContext.workThemes = realmInstance.allObjectsAsArray()
        self.sharedContext.packsInCourses = realmInstance.allObjectsAsArray()
        
        self.sharedContext.lessons = realmInstance.allObjectsAsArray()
        self.sharedContext.works = realmInstance.allObjectsAsArray()
        self.sharedContext.workStages = realmInstance.allObjectsAsArray()
        self.sharedContext.workProcs = realmInstance.allObjectsAsArray()
        self.sharedContext.formCoursesWithPacks()
        self.sharedContext.formGroupsWithStudents()
//        self.sharedContext.formLessonsWithVisits()
        Pack.addGroups()
    }
}

extension Realm{
    
    func allObjectsAsArray<T: Object>()->[T]{
        return self.objects(T.self).toArray()
    }
}
