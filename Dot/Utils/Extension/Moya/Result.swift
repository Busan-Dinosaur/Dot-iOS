//
//  Result.swift
//  FoodBowl
//
//  Created by Coby on 12/29/23.
//

import Foundation

import Moya

extension Result<Response, MoyaError> {
    func decode<T: Decodable>() throws -> T {
        switch self {
        case .success(let result):
            let data = try result.map(T.self)
            return data
        case .failure(let error):
            if let errorResponse = error.errorResponse {
                print("에러 코드: \(errorResponse.errorCode)")
                print("에러 메시지: \(errorResponse.message)")
                
                throw CustomError.error(message: errorResponse.message)
            } else {
                print("네트워크 에러: \(error.localizedDescription)")
                throw CustomError.unknownError
            }
        }
    }
}

extension MoyaError {
    var errorResponse: ErrorDTO? {
        if let response = response {
            do {
                return try response.map(ErrorDTO.self)
            } catch {
                print("에러 데이터 매핑에 실패했습니다.")
                return nil
            }
        }
        return nil
    }
}
