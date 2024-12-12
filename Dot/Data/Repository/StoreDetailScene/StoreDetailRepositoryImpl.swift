//
//  StoreDetailRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 1/17/24.
//

import Foundation

import Moya

final class StoreDetailRepositoryImpl: StoreDetailRepository {
    
    private let provider = MoyaProvider<ServiceAPI>()
    
    func getReviewsByStore(request: GetReviewsByStoreRequestDTO) async throws -> ReviewByStoreDTO {
        let response = await provider.request(.getReviewsByStore(request: request))
        return try response.decode()
    }
    
    func createBookmark(storeId: Int) async throws {
        let _ = await provider.request(.createBookmark(storeId: storeId))
    }
    
    func removeBookmark(storeId: Int) async throws {
        let _ = await provider.request(.removeBookmark(storeId: storeId))
    }
    
    func removeReview(id: Int) async throws {
        let _ = await provider.request(.removeReview(id: id))
    }
}
