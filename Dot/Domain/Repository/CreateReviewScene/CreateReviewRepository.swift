//
//  CreateReviewRepository.swift
//  FoodBowl
//
//  Created by Coby on 1/18/24.
//

import Foundation

protocol CreateReviewRepository {
    func searchStores(x: String, y: String, keyword: String) async throws -> PlaceDTO
    func searchUniv(x: String, y: String) async throws -> PlaceDTO
    func searchStoresByLocation(x: String, y: String) async throws -> PlaceDTO
    func createReview(request: CreateReviewRequestDTO, images: [Data]) async throws
}
