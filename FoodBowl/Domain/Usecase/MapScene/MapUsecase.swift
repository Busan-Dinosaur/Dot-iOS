//
//  MapUsecase.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import Foundation

protocol MapUsecase {
    func getReviewsByBound(request: GetReviewsRequestDTO) async throws -> Reviews
    func getReviewsByFollowing(request: GetReviewsRequestDTO) async throws -> Reviews
    func getReviewsByBookmark(request: GetReviewsRequestDTO) async throws -> Reviews
    func getStoresByBound(request: CustomLocationRequestDTO) async throws -> [Store]
    func getStoresByFollowing(request: CustomLocationRequestDTO) async throws -> [Store]
    func getStoresByBookmark(request: CustomLocationRequestDTO) async throws -> [Store]
    func createBookmark(storeId: Int) async throws
    func removeBookmark(storeId: Int) async throws
}

final class MapUsecaseImpl: MapUsecase {
    
    // MARK: - property
    
    private let repository: MapRepository
    
    // MARK: - init
    
    init(repository: MapRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
    
    func getReviewsByBound(request: GetReviewsRequestDTO) async throws -> Reviews {
        do {
            let reviewDTO = try await self.repository.getReviewsByBound(request: request)
            return reviewDTO.toReviews()
        } catch(let error) {
            throw error
        }
    }
    
    func getReviewsByFollowing(request: GetReviewsRequestDTO) async throws -> Reviews {
        do {
            let reviewDTO = try await self.repository.getReviewsByFollowing(request: request)
            return reviewDTO.toReviews()
        } catch(let error) {
            throw error
        }
    }
    
    func getReviewsByBookmark(request: GetReviewsRequestDTO) async throws -> Reviews {
        do {
            let reviewDTO = try await self.repository.getReviewsByBookmark(request: request)
            return reviewDTO.toReviews()
        } catch(let error) {
            throw error
        }
    }
    
    func getStoresByBound(request: CustomLocationRequestDTO) async throws -> [Store] {
        do {
            let storeDTO = try await self.repository.getStoresByBound(request: request)
            return storeDTO.stores.map { $0.toStore() }
        } catch(let error) {
            throw error
        }
    }
    
    func getStoresByFollowing(request: CustomLocationRequestDTO) async throws -> [Store] {
        do {
            let storeDTO = try await self.repository.getStoresByFollowing(request: request)
            return storeDTO.stores.map { $0.toStore() }
        } catch(let error) {
            throw error
        }
    }
    
    func getStoresByBookmark(request: CustomLocationRequestDTO) async throws -> [Store] {
        do {
            let storeDTO = try await self.repository.getStoresByBookmark(request: request)
            return storeDTO.stores.map { $0.toStore() }
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
}
