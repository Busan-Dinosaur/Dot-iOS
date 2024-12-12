//
//  KeychainManager.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/08/09.
//

import Foundation

import KeychainSwift

struct KeychainManager {
    static var keychain: KeychainSwift = .init(keyPrefix: "FoodBowl")

    static func set(_ value: String, for key: Key) {
        keychain.set(value, forKey: key.rawValue)
    }

    static func set(_ value: Data, for key: Key) {
        keychain.set(value, forKey: key.rawValue)
    }

    static func set(_ value: Bool, for key: Key) {
        keychain.set(value, forKey: key.rawValue)
    }

    static func get(_ key: Key, defaultValue: String = "") -> String {
        return keychain.get(key.rawValue) ?? defaultValue
    }

    static func getData(_ key: Key, defaultValue: Data = .init()) -> Data {
        return keychain.getData(key.rawValue) ?? defaultValue
    }

    static func getBool(_ key: Key, defaultValue: Bool = false) -> Bool {
        return keychain.getBool(key.rawValue) ?? defaultValue
    }

    static func delete(_ key: Key) {
        keychain.delete(key.rawValue)
    }

    static func clear() {
        keychain.clear()
    }

    static func allKeys() -> [Key] {
        return Key.allCases
    }

    enum Key: String, CaseIterable {
        case accessToken
        case refreshToken
    }
}
