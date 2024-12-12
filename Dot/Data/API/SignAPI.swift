//
//  SignAPI.swift
//  FoodBowl
//
//  Created by Coby on 1/29/24.
//

import Foundation

import Moya

enum SignAPI {
    case signIn(request: SignRequestDTO)
    case patchRefreshToken(token: Token)
    case logOut
    case signOut
    case getMyProfile
}

extension SignAPI: TargetType {
    var baseURL: URL {
        @Configurations(key: ConfigurationsKey.baseURL, defaultValue: "")
        var baseURL: String
        return URL(string: baseURL)!
    }

    var path: String {
        switch self {
        case .signIn:
            return "/v1/auth/login/oauth/apple"
        case .patchRefreshToken:
            return "/v1/auth/token/renew"
        case .logOut:
            return "/v1/auth/logout"
        case .signOut:
            return "/v1/members/deactivate"
        case .getMyProfile:
            return "/v1/members/me/profile"
        }
    }

    var method: Moya.Method {
        switch self {
        case .signIn, .patchRefreshToken, .logOut:
            return .post
        case .getMyProfile:
            return .get
        case .signOut:
            return .delete
        }
    }

    var task: Task {
        switch self {
        case .signIn(let request):
            return .requestJSONEncodable(request)
        case .patchRefreshToken(let request):
            let request = Token(
                accessToken: request.accessToken,
                refreshToken: request.refreshToken
            )
            return .requestJSONEncodable(request)
        default:
            return .requestPlain
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
                "Authorization": "Bearer " + accessToken
            ]
        }
    }

    var validationType: ValidationType { .successCodes }
}
