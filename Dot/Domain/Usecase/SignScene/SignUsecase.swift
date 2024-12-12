//
//  SignUsecase.swift
//  FoodBowl
//
//  Created by COBY_PRO on 11/9/23.
//

import Foundation

protocol SignUsecase {
    func dispatchAppleLogin(login: SignRequestDTO) async throws -> Token
    func getMyProfile() async throws -> Member
}

final class SignUsecaseImpl: SignUsecase {
    
    // MARK: - property
    
    private let repository: SignRepository
    
    // MARK: - init
    
    init(repository: SignRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
    
    func dispatchAppleLogin(login: SignRequestDTO) async throws -> Token {
        do {
            let token = try await self.repository.signIn(request: login)
            return token
        } catch(let error) {
            throw error
        }
    }
    
    func getMyProfile() async throws -> Member {
        do {
            let MemberProfileDTO = try await self.repository.getMyProfile()
            return MemberProfileDTO.toMember()
        } catch(let error) {
            throw error
        }
    }
}
