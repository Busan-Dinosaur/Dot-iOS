//
//  BlameUsecase.swift
//  FoodBowl
//
//  Created by Coby on 12/31/23.
//

import Foundation

protocol BlameUsecase {
    func createBlame(request: CreateBlameRequestDTO) async throws
}

final class BlameUsecaseImpl: BlameUsecase {
    
    // MARK: - property
    
    private let repository: BlameRepository
    
    // MARK: - init
    
    init(repository: BlameRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
    
    func createBlame(request: CreateBlameRequestDTO) async throws {
        do {
            try await self.repository.createBlame(request: request)
        } catch(let error) {
            throw error
        }
    }
}
