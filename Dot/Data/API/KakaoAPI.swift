//
//  KakaoAPI.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/09/10.
//

import Foundation

import Moya

enum KakaoAPI {
    case searchStores(x: String, y: String, keyword: String)
    case searchUniv(x: String, y: String)
    case searchStoresByLocation(x: String, y: String)
    case searchPlaces(x: String, y: String, keyword: String)
}

extension KakaoAPI: TargetType {
    var baseURL: URL {
        @Configurations(key: ConfigurationsKey.kakaoURL, defaultValue: "")
        var kakaoURL: String
        return URL(string: kakaoURL)!
    }

    var path: String {
        switch self {
        case .searchStores, .searchUniv, .searchPlaces:
            return "/v2/local/search/keyword"
        case .searchStoresByLocation:
            return "/v2/local/search/category"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case .searchStores(let x, let y, let keyword):
            let params: [String: Any] = [
                "query": keyword,
                "x": x,
                "y": y,
                "page": 1,
                "size": 15,
                "category_group_code": "FD6,CE7"
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .searchUniv(let x, let y):
            let params: [String: Any] = [
                "query": "대학교",
                "x": x,
                "y": y,
                "page": 1,
                "size": 1,
                "radius": 1000,
                "category_group_code": "SC4"
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .searchStoresByLocation(let x, let y):
            let params: [String: Any] = [
                "x": x,
                "y": y,
                "page": 1,
                "size": 15,
                "radius": 100,
                "category_group_code": "FD6,CE7"
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .searchPlaces(let x, let y, let keyword):
            let params: [String: Any] = [
                "query": keyword,
                "x": x,
                "y": y,
                "page": 1,
                "size": 15
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        }
    }

    var headers: [String: String]? {
        @Configurations(key: ConfigurationsKey.kakaoToken, defaultValue: "")
        var kakaoToken: String

        return [
            "Content-Type": "application/x-www-form-urlencoded;charset=utf-8",
            "Authorization": "KakaoAK " + kakaoToken
        ]
    }

    var validationType: ValidationType { .successCodes }
}
