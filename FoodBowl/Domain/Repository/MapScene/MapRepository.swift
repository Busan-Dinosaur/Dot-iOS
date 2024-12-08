//
//  MapRepository.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import Foundation

protocol MapRepository {
    func getReviewsByBound(request: GetReviewsRequestDTO) async throws -> ReviewDTO
    func getReviewsByFollowing(request: GetReviewsRequestDTO) async throws -> ReviewDTO
    func getReviewsByBookmark(request: GetReviewsRequestDTO) async throws -> ReviewDTO
    func getReviewsByMember(request: GetReviewsByMemberRequestDTO) async throws -> ReviewDTO
    func getStoresByBound(request: CustomLocationRequestDTO) async throws -> StoreDTO
    func getStoresByFollowing(request: CustomLocationRequestDTO) async throws -> StoreDTO
    func getStoresByBookmark(request: CustomLocationRequestDTO) async throws -> StoreDTO
    func getStoresByMember(request: GetStoresByMemberRequestDTO) async throws -> StoreDTO
    func createBookmark(storeId: Int) async throws
    func removeBookmark(storeId: Int) async throws
}
