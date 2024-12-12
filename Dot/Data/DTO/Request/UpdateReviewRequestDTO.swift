//
//  UpdateReviewRequestDTO.swift
//  FoodBowl
//
//  Created by Coby on 1/24/24.
//

import Foundation

struct UpdateReviewRequestDTO: Encodable {
    let reviewContent: String
    let deletePhotoIds: [Int]
}
