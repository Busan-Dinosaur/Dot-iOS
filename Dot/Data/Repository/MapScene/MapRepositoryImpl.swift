//
//  MapRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import Foundation

import Moya

final class MapRepositoryImpl: MapRepository {

    private let provider = MoyaProvider<ServiceAPI>()
    
    func getReviewsByBound(request: GetReviewsRequestDTO) async throws -> ReviewDTO {
        let response = await provider.request(.getReviewsByBound(request: request))
        return try response.decode()
    }
    
    func getReviewsByFollowing(request: GetReviewsRequestDTO) async throws -> ReviewDTO {
        let response = await provider.request(.getReviewsByFollowing(request: request))
        return try response.decode()
    }
    
    func getReviewsByBookmark(request: GetReviewsRequestDTO) async throws -> ReviewDTO {
        let response = await provider.request(.getReviewsByBookmark(request: request))
        return try response.decode()
    }
    
    func getReviewsByMember(request: GetReviewsByMemberRequestDTO) async throws -> ReviewDTO {
        let response = await provider.request(.getReviewsByMember(request: request))
        return try response.decode()
    }
    
    func getStoresByBound(request: CustomLocationRequestDTO) async throws -> StoreDTO {
        let response = await provider.request(.getStoresByBound(request: request))
        return try response.decode()
    }
    
    func getStoresByFollowing(request: CustomLocationRequestDTO) async throws -> StoreDTO {
        let response = await provider.request(.getStoresByFollowing(request: request))
        return try response.decode()
    }
    
    func getStoresByBookmark(request: CustomLocationRequestDTO) async throws -> StoreDTO {
        let response = await provider.request(.getStoresByBookmark(request: request))
        return try response.decode()
    }
    
    func getStoresByMember(request: GetStoresByMemberRequestDTO) async throws -> StoreDTO {
        let response = await provider.request(.getStoresByMember(request: request))
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
