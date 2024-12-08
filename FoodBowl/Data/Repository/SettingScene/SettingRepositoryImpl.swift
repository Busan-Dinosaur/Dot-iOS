//
//  SettingRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 2/1/24.
//

import Foundation

import Moya

final class SettingRepositoryImpl: SettingRepository {
    
    private let provider = MoyaProvider<SignAPI>()
    
    func logOut() async throws {
        let _ = await provider.request(.logOut)
    }
    
    func signOut() async throws {
        let _ = await provider.request(.signOut)
    }
}
