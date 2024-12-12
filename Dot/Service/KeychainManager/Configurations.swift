//
//  Configurations.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/08/09.
//

import Foundation

enum ConfigurationsKey: String {
    case nonce = "Nonce"
    case baseURL = "BaseURL"
    case kakaoURL = "KakaoURL"
    case kakaoToken = "KakaoToken"
}

@propertyWrapper
struct Configurations<K, T> where K: RawRepresentable, K.RawValue == String {
    let key: K
    let defaultValue: T

    init(key: K, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key.rawValue) as? T
        else {
            fatalError("Invalid Configuration Value")
        }
        return value
    }
}
