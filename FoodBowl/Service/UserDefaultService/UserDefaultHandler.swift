//
//  UserDefaultHandler.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/02/01.
//

import Foundation

struct UserDefaultHandler {
    static func clearAllData() {
        UserData<Any>.clearAll()
    }
    
    static func setInAppReviewCount(inAppReviewCount: Int) {
        UserData.setValue(inAppReviewCount, forKey: .inAppReviewCount)
    }
    
    static func setIsLogin(isLogin: Bool) {
        UserData.setValue(isLogin, forKey: .isLogin)
    }
    
    static func setTokenExpiryDate(tokenExpiryDate: Date) {
        UserData.setValue(tokenExpiryDate, forKey: .tokenExpiryDate)
    }
    
    static func setId(id: Int) {
        UserData.setValue(id, forKey: .id)
    }
    
    static func setNickname(nickname: String) {
        UserData.setValue(nickname, forKey: .nickname)
    }
}
