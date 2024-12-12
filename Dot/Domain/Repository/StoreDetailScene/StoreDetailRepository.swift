//
//  StoreDetailRepository.swift
//  FoodBowl
//
//  Created by Coby on 1/17/24.
//

import Foundation

protocol StoreDetailRepository {
    func getReviewsByStore(request: GetReviewsByStoreRequestDTO) async throws -> ReviewByStoreDTO
    func createBookmark(storeId: Int) async throws
    func removeBookmark(storeId: Int) async throws
    func removeReview(id: Int) async throws
}
