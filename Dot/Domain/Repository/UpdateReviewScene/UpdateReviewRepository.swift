//
//  UpdateReviewRepository.swift
//  FoodBowl
//
//  Created by Coby on 1/22/24.
//

import Foundation

protocol UpdateReviewRepository {
    func getReview(request: GetReviewRequestDTO) async throws -> ReviewItemDTO
    func updateReview(id: Int, request: UpdateReviewRequestDTO, images: [Data]) async throws
}
