//
//  SettingRepository.swift
//  FoodBowl
//
//  Created by Coby on 2/1/24.
//

import Foundation

protocol SettingRepository {
    func logOut() async throws
    func signOut() async throws
}
