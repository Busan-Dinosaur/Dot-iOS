//
//  UpdateReviewRepositoryImpl.swift
//  FoodBowl
//
//  Updated by Coby on 1/24/24.
//

import Foundation

import Moya

final class UpdateReviewRepositoryImpl: UpdateReviewRepository {
    
    private let provider = MoyaProvider<ServiceAPI>()
    
    func getReview(request: GetReviewRequestDTO) async throws -> ReviewItemDTO {
        let response = await provider.request(.getReview(request: request))
        return try response.decode()
    }
    
    func updateReview(id: Int, request: UpdateReviewRequestDTO, images: [Data]) async throws {
        let _ = await provider.request(.updateReview(id: id, request: request, images: images))
    }
}
