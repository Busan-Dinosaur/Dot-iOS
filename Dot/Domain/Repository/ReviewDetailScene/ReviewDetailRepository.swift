//
//  ReviewDetailRepository.swift
//  FoodBowl
//
//  Created by Coby on 1/24/24.
//

import Foundation

protocol ReviewDetailRepository {
    func getReview(request: GetReviewRequestDTO) async throws -> ReviewItemDTO
    func createBookmark(storeId: Int) async throws
    func removeBookmark(storeId: Int) async throws
    func removeReview(id: Int) async throws
}
