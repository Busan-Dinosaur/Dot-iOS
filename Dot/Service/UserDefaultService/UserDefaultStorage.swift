//
//  UserDefaultStorage.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/02/01.
//

import Foundation

enum DataKeys: String, CaseIterable {
    case inAppReviewCount
    case isLogin
    case tokenExpiryDate
    case id
    case nickname
}

enum UserDefaultStorage {
    static var inAppReviewCount: Int {
        return UserData<Int>.getValue(forKey: .inAppReviewCount) ?? 0
    }
    
    static var isLogin: Bool {
        return UserData<Bool>.getValue(forKey: .isLogin) ?? false
    }
    
    static var tokenExpiryDate: Date {
        return UserData<Date>.getValue(forKey: .tokenExpiryDate) ?? .now
    }
    
    static var id: Int {
        return UserData<Int>.getValue(forKey: .id) ?? 0
    }
    
    static var nickname: String {
        return UserData<String>.getValue(forKey: .nickname) ?? ""
    }
}

enum UserData<T> {
    static func getValue(forKey key: DataKeys) -> T? {
        if let data = UserDefaults.standard.value(forKey: key.rawValue) as? T {
            return data
        } else {
            return nil
        }
    }

    static func setValue(_ value: T, forKey key: DataKeys) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func clearAll() {
        DataKeys.allCases.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }

    static func clear(forKey key: DataKeys) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
