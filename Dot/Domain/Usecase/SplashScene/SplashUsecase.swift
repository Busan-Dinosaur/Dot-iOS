//
//  SplashUsecase.swift
//  FoodBowl
//
//  Created by Coby on 2/1/24.
//

import Foundation

protocol SplashUsecase {
    func patchRefreshToken(token: Token) async throws -> Token
}

final class SplashUsecaseImpl: SplashUsecase {
    
    // MARK: - property
    
    private let repository: SplashRepository
    
    // MARK: - init
    
    init(repository: SplashRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
    
    func patchRefreshToken(token: Token) async throws -> Token {
        do {
            let token = try await self.repository.patchRefreshToken(token: token)
            return token
        } catch(let error) {
            throw error
        }
    }
}
