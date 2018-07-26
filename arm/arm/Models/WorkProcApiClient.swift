//
//  WorkProcApiClient.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 30.10.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

import Alamofire
import Alamofire_Synchronous

class WorkProcApiURLConfig {
    
    private let baseApiUrl: String
    
    init(baseApiUrl: String){
        self.baseApiUrl = baseApiUrl
    }
    
    func newWorkProcVersionsPOSTURL() -> String {
        return self.baseApiUrl + "NewWorkProcVersions"
    }
    
    func newWorkProcVersionsURL(for packId: Int) -> String {
        return self.baseApiUrl + "NewWorkProcVersions/"+"\(packId)"
    }
    
    func fullWorkProcURL(for serverWorkProcId: Int) -> String {
        return self.baseApiUrl + "NewWorkProc/"+"\(serverWorkProcId)"
    }
    
    func changeWorkProcURL() -> String {
        return self.baseApiUrl + "NewWorkProcVersions/"
    }
    
    func getStudentWorkProcVersionsURL(for serverWorkProcId: Int) -> String {
        return self.baseApiUrl + "NewStudentWorkProcInfo/"+"\(serverWorkProcId)"
    }
    
    func getStudentWorkProcFullInfoURL(for serevrStudentWorkProcId: Int) -> String {
        return self.baseApiUrl + "NewStudentWorkProcCommit/"+"\(serevrStudentWorkProcId)"
    }
    
    func changeStudentWorkProcURL() -> String {
        return self.baseApiUrl + "NewStudentWorkProcCommit"
    }
    
    func getWorkThemesURL(for workId: Int) -> String {
        return self.baseApiUrl + "WorkThemeCommit/" + "\(workId)"
    }
    
    func getRatingItemsURL(for courseId: Int) -> String {
        return self.baseApiUrl + "RatingCommit/?courseId=" + "\(courseId)"
    }
    
    func ratingCommitURL() -> String {
        return self.baseApiUrl + "RatingCommit"
    }
    
    func deleteRatingURL() -> String {
        return self.baseApiUrl + "RatingDelete"
    }
    
}

class WorkProcApiClient: NSObject {

    let apiConfig: WorkProcApiURLConfig
    
    init(apiConfig: WorkProcApiURLConfig){
        self.apiConfig = apiConfig
    }
    
    func newWorkProcVersionsPost(for workProc:WorkProc) throws -> Int {
        let parameters: Parameters = workProc.dictionary()
        let encoding = Alamofire.JSONEncoding.default
        
        let response = Alamofire.request(apiConfig.newWorkProcVersionsPOSTURL(),
                                         method: .post,
                                         parameters: parameters,
                                         encoding: encoding).responseJSON()
        guard let responseJSON = response.result.value as? AnyObject else{
            print("error: \(response)")
            throw HttpError()
        }
        
        return Int(responseJSON as! NSNumber)
    }
    
    func newWorkProcVersions(for packId: Int) throws -> [WorkProcVersionInfo] {
        let response = Alamofire.request(apiConfig.newWorkProcVersionsURL(for: packId), method: .get).responseJSON()
        
        guard let responseDictionary = response.result.value as? [Dictionary<String, Any>] else {
            print("error: \(response)")
            throw HttpError()
        }
        
        let result = responseDictionary.map{ WorkProcVersionInfo(json: $0) }
        
        return result

    }
    
    func getFullWorkProcInfo(for workProcId: Int) throws -> WorkProcModel {
        
        let response = Alamofire.request(apiConfig.fullWorkProcURL(for: workProcId), method: .get).responseJSON()
        guard let responseJSON = response.result.value as? [String: AnyObject] else {
            print("error: \(response)")
            throw HttpError()
        }
        
        return WorkProcModel(json: responseJSON)
    }
    
    func getNewStudentWorkProcInfo(for workProcId: Int) throws -> [StudentWorkProcModel] {
        let response = Alamofire.request(apiConfig.getStudentWorkProcVersionsURL(for: workProcId), method: .get).responseJSON()
        guard let responseDictionary = response.result.value as? [Dictionary<String, Any>] else {
            print("error: \(response)")
            throw HttpError()
        }
        
        let result = responseDictionary.map{ StudentWorkProcModel(json: $0) }
        
        return result
    }
    
    func newStudentWorkProcCommit(for studentWorkProc:StudentWorkProc) throws -> StudentProcUpdateResponse {
        let parameters: Parameters = studentWorkProc.dictionary()
        let encoding = Alamofire.JSONEncoding.default
        
        let response = Alamofire.request(apiConfig.changeStudentWorkProcURL(),
                                         method: .post,
                                         parameters: parameters,
                                         encoding: encoding).responseJSON()
        guard let responseJSON = response.result.value as? [String: AnyObject] else{
            print("error: \(response)")
            throw HttpError()
        }
        
        return StudentProcUpdateResponse(updateJson: responseJSON)
        
    }
    
    func getNewStudentWorkProcCommit(for studentWorkProcId: Int) throws -> StudentWorkProcModel {
        let response = Alamofire.request(apiConfig.getStudentWorkProcFullInfoURL(for: studentWorkProcId),
                                         method: .get).responseJSON()
        guard let responseDictionary = response.result.value as? Dictionary<String, Any> else {
            print("error: \(response)")
            throw HttpError()
        }
        
        let result = StudentWorkProcModel(json: responseDictionary)
        
        return result
    }
    
    func getWorkThemes(workId: Int) throws -> [WorkTheme] {
        let response = Alamofire.request(apiConfig.getWorkThemesURL(for: workId),
                                         method: .get).responseJSON()
        guard let responseDictionary = response.result.value as? [Dictionary<String, Any>] else {
            guard let responseSingleObject = response.result.value as? Dictionary<String, Any> else {
                return []
            }
            let result = WorkTheme(json: responseSingleObject)
            return [result]
        }
        
        let result = responseDictionary.map{ WorkTheme(json: $0) }
        return result
    }
    
    func getRatingItems(courseId: Int) throws -> [RatingItem] {
        let response = Alamofire.request(apiConfig.getRatingItemsURL(for: courseId), method: .get).responseJSON()
        guard let responceDictionary = response.result.value as? [Dictionary<String, Any>] else {
            print("error: \(response)")
            throw HttpError()
        }
        
        let result = RatingItem.serializeRatingItems(ratingItemsArray: responceDictionary)
        return result
    }
    
    func commitRatingItem(ratingItem: RatingItem) throws -> RatingItem {
        let items = [ratingItem.dictionaryRepresentation()]

        let url = URL(string: apiConfig.ratingCommitURL())!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: items)
        
        let response = Alamofire.request(request).responseJSON()

        guard let responseJSON = response.result.value as? [Dictionary<String, Any>] else{
            print("error: \(response)")
            throw HttpError()
        }
        
        let result = RatingItem.serializeRatingItems(ratingItemsArray: responseJSON)
        return result.first!
    }
    
    func deleteRatings(ratingItems: [RatingItem]) throws -> [Int] {

        let url = URL(string: apiConfig.deleteRatingURL())!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try! JSONSerialization.data(withJSONObject: RatingItem.ratingIdsToString(ratingItems: ratingItems))

        let response = Alamofire.request(request).responseJSON()

        if let arrayValues = response.result.value as? [Int] {
            return arrayValues
        }
        
        if let value = response.result.value as? Int {
            return [value]
        }
        
        print("error: \(response)")
        throw HttpError()
    }
    
}
