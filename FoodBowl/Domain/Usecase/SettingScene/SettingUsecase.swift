//
//  SettingUsecase.swift
//  FoodBowl
//
//  Created by Coby on 2/1/24.
//

import Foundation

protocol SettingUsecase {
    func getMyProfile() async throws -> Member
    func logOut() async throws
    func signOut() async throws
}

final class SettingUsecaseImpl: SettingUsecase {
    
    // MARK: - property
    
    private let repository: SettingRepository
    
    // MARK: - init
    
    init(repository: SettingRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
    
    func getMyProfile() async throws -> Member {
        do {
            let myProfileDTO = try await self.repository.getMyProfile()
            return myProfileDTO.toMember()
        } catch(let error) {
            throw error
        }
    }
    
    func logOut() async throws {
        do {
            try await self.repository.logOut()
        } catch(let error) {
            throw error
        }
    }
    
    func signOut() async throws {
        do {
            try await self.repository.signOut()
        } catch(let error) {
            throw error
        }
    }
}
