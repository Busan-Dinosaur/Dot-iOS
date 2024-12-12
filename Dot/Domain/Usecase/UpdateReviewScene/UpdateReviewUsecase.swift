//
//  UpdateReviewUsecase.swift
//  FoodBowl
//
//  Updated by Coby on 1/22/24.
//

import Foundation

protocol UpdateReviewUsecase {
    func getReview(request: GetReviewRequestDTO) async throws -> Review
    func updateReview(id: Int, request: UpdateReviewRequestDTO, images: [Data]) async throws
}

final class UpdateReviewUsecaseImpl: UpdateReviewUsecase {
    
    // MARK: - property
    
    private let repository: UpdateReviewRepository
    
    // MARK: - init
    
    init(repository: UpdateReviewRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
    
    func getReview(request: GetReviewRequestDTO) async throws -> Review {
        do {
            let reviewItemDTO = try await self.repository.getReview(request: request)
            return reviewItemDTO.toReview()
        } catch(let error) {
            throw error
        }
    }
    
    func updateReview(id: Int, request: UpdateReviewRequestDTO, images: [Data]) async throws {
        do {
            try await self.repository.updateReview(id: id, request: request, images: images)
        } catch(let error) {
            throw error
        }
    }
}
