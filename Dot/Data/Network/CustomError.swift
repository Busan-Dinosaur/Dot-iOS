//
//  CustomError.swift
//  FoodBowl
//
//  Created by Coby on 12/29/23.
//

import Foundation

enum CustomError: LocalizedError {
    case error(message: String)
    case unknownError
    case clientError
}

extension CustomError {
    var errorDescription: String {
        switch self {
        case .error(let message):
            return message
        case .unknownError:
            return "알 수 없는 에러가 발생했습니다."
        case .clientError:
            return "네트워크 통신에 실패하였습니다."
        }
    }
}
