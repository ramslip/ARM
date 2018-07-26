//
//  ErrorsManager.swift
//  arm
//
//  Created by Ekaterina Lapkovskaya on 17.08.17.
//  Copyright © 2017 Ekaterina Lapkovskaya. All rights reserved.
//

import UIKit

public enum StatusCodes: Int {
    case outOfNetwork = 100
    case wrongLoginOrPassword = 400
    case ok = 200
}

class StatusCodeManager: NSObject
{
    class func getStatusCodeDescription(statusCode: Int) -> String {
        switch statusCode {
        case StatusCodes.outOfNetwork.rawValue:
            return "Проверьте соединение с Интернетом"
        case StatusCodes.wrongLoginOrPassword.rawValue:
            return "Неверный логин или пароль"
        case StatusCodes.ok.rawValue:
            return "Успешно"
        default:
            return "Упс... Что-то пошло не так :("
        }
    }
}
