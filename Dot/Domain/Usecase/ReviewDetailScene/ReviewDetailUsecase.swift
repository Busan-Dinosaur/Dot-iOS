//
//  ReviewDetailUsecase.swift
//  FoodBowl
//
//  Created by Coby on 1/24/24.
//

import Foundation

protocol ReviewDetailUsecase {
    func getReview(request: GetReviewRequestDTO) async throws -> Review
    func createBookmark(storeId: Int) async throws
    func removeBookmark(storeId: Int) async throws
    func removeReview(id: Int) async throws
}

final class ReviewDetailUsecaseImpl: ReviewDetailUsecase {
    
    // MARK: - property
    
    private let repository: ReviewDetailRepository
    
    // MARK: - init
    
    init(repository: ReviewDetailRepository) {
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
    
    func createBookmark(storeId: Int) async throws {
        do {
            try await self.repository.createBookmark(storeId: storeId)
        } catch(let error) {
            throw error
        }
    }
    
    func removeBookmark(storeId: Int) async throws {
        do {
            try await self.repository.removeBookmark(storeId: storeId)
        } catch(let error) {
            throw error
        }
    }
    
    func removeReview(id: Int) async throws {
        do {
            try await self.repository.removeReview(id: id)
        } catch(let error) {
            throw error
        }
    }
}
