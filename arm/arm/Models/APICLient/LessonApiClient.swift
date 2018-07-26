//
//  LessonApiClient.swift
//  arm
//
//  Created by Victor Kalevko on 21.10.2017.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

import Alamofire

class LessonApiURLConfig {
    
    private let baseApiUrl: String
    
    init(baseApiUrl: String){
        self.baseApiUrl = baseApiUrl
    }
    
    func lessonDatesURL(for packId: Int) -> String{
        return self.baseApiUrl + "LessonDates/"+"\(packId)"
    }
    
    func fullLessonURL(for serverLessonId: Int) -> String {
        return self.baseApiUrl + "LessonInfo/"+"\(serverLessonId)"
    }
    
    func createLessonURL() -> String {
        return self.baseApiUrl + "LessonCreate"
    }
    
    func commitLessonURL() -> String {
        return self.baseApiUrl + "LessonCommit"
    }
}

class LessonApiClient: NSObject {

    let apiConfig: LessonApiURLConfig
    
    init(apiConfig: LessonApiURLConfig){
        self.apiConfig = apiConfig
    }
    
    func getLessonDates(for packId: Int) throws -> [LessonDateInfo] {
        
        let response = Alamofire.request(apiConfig.lessonDatesURL(for: packId), method: .get).responseJSON()
        
        guard let responseDictionary = response.result.value as? [Dictionary<String, Any>] else{
            print("error: \(response)")
            throw HttpError()
        }
        
        let result = responseDictionary.map{ LessonDateInfo(json: $0) }
        
        return result
    }
    
    func getFullLessonInfo(for serverLessonId: Int) throws -> LessonModel {
        
        let response = Alamofire.request(apiConfig.fullLessonURL(for: serverLessonId), method: .get).responseJSON()
        
        guard let responseJSON = response.result.value as? [String: AnyObject] else{
            print("error: \(response)")
            throw HttpError()
        }
        
        return LessonModel(json: responseJSON)
    }
    
    func createLesson(createLessonData: LessonModel) throws -> LessonModel {
        let parameters: Parameters = createLessonData.dictionary()
        let encoding = Alamofire.JSONEncoding.default
        
        let response = Alamofire.request(apiConfig.createLessonURL(),
                                         method: .post,
                                         parameters: parameters,
                                         encoding: encoding).responseJSON()
        
        guard let responseJSON = response.result.value as? [String: AnyObject] else{
            print("error: \(response)")
            throw HttpError()
        }
        
        return LessonModel(json: responseJSON)
    }
    
    func updateLesson(updateLesonData: LessonModel) throws -> UpdateLessonResponseData {
        let parameters: Parameters = updateLesonData.dictionary()
        let encoding = Alamofire.JSONEncoding.default
        
        let response = Alamofire.request(apiConfig.commitLessonURL(),
                                         method: .post,
                                         parameters: parameters,
                                         encoding: encoding).responseJSON()
        
        guard let responseJSON = response.result.value as? [String: AnyObject] else{
            print("error: \(response)")
            throw HttpError()
        }
        
        return UpdateLessonResponseData(json: responseJSON)
        
    }
    
    func deleteLesson(serverLessonId: Int) throws -> Bool {
        
        let encoding = Alamofire.JSONEncoding.default
        let null = NSNull()
        let parameters: Parameters = ["\(serverLessonId)" : null]
        
        let response = Alamofire.request(apiConfig.commitLessonURL(),
                                         method: .delete,
                                         parameters: parameters,
                                         encoding: encoding).responseJSON()
        
        print("deleteLessonResponse: \(String(describing: response.response))")

        return response.response?.statusCode == 200
    }
}
