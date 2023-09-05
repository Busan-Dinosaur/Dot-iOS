//
//  UserAPI.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/08/09.
//

import Foundation

import Moya

enum UserAPI {
    case signIn(form: SignRequest)
    case renew(form: RenewRequest)
    case updateProfile(form: UpdateProfileRequest)
    case getMemberProfile(id: Int)
    case checkNickname(nickname: String)
}

extension UserAPI: TargetType {
    var baseURL: URL {
        @Configurations(key: ConfigurationsKey.baseURL, defaultValue: "")
        var baseURL: String
        return URL(string: baseURL)!
    }

    var path: String {
        switch self {
        case .signIn:
            return "/v1/auth/login/oauth/apple"
        case .renew:
            return "/v1/auth/token/renew"
        case .updateProfile:
            return "/v1/members/profile"
        case .getMemberProfile(let id):
            return "/v1/members/\(id)/profile"
        case .checkNickname:
            return "/v1/members/nickname/exist"
        }
    }

    var method: Moya.Method {
        switch self {
        case .signIn:
            return .post
        case .renew:
            return .post
        case .updateProfile:
            return .patch
        default:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .signIn(let form):
            return .requestJSONEncodable(form)
        case .renew(let form):
            return .requestJSONEncodable(form)
        case .updateProfile(let form):
            return .requestJSONEncodable(form)
        case .getMemberProfile:
            return .requestPlain
        case .checkNickname(let nickname):
            let params: [String: String] = [
                "nickname": nickname
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        }
    }

    var headers: [String: String]? {
        switch self {
        case .signIn:
            return [
                "Content-Type": "application/json"
            ]
        default:
            let accessToken: String = KeychainManager.get(.accessToken)

            return [
                "Content-Type": "application/json",
                "Authorization": accessToken
            ]
        }
    }

    var validationType: ValidationType { .successCodes }
}