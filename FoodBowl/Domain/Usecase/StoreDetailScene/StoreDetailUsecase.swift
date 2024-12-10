//
//  StoreDetailUsecase.swift
//  FoodBowl
//
//  Created by Coby on 1/17/24.
//

import Foundation

protocol StoreDetailUsecase {
    func getReviewsByStore(request: GetReviewsByStoreRequestDTO) async throws -> Reviews
    func createBookmark(storeId: Int) async throws
    func removeBookmark(storeId: Int) async throws
    func removeReview(id: Int) async throws
}

final class StoreDetailUsecaseImpl: StoreDetailUsecase {
    
    // MARK: - property
    
    private let repository: StoreDetailRepository
    
    // MARK: - init
    
    init(repository: StoreDetailRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
    
    func getReviewsByStore(request: GetReviewsByStoreRequestDTO) async throws -> Reviews {
        do {
            let reviewByStoreDTO = try await self.repository.getReviewsByStore(request: request)
            return reviewByStoreDTO.toReviews()
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
