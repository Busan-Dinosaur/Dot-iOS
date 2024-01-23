//
//  GetReviewsRequestDTO.swift
//  FoodBowl
//
//  Created by Coby on 12/29/23.
//

struct GetReviewRequestDTO: Encodable {
    let id: Int
    let deviceX, deviceY: Double
}

struct GetReviewsRequestDTO: Encodable {
    let location: CustomLocationRequestDTO
    let lastReviewId: Int?
    let pageSize: Int
}

struct GetReviewsByStoreRequestDTO: Encodable {
    let lastReviewId: Int?
    let pageSize: Int
    let storeId: Int
    let filter: String
    let deviceX, deviceY: Double
}

struct GetReviewsBySchoolRequestDTO: Encodable {
    let location: CustomLocationRequestDTO
    let lastReviewId: Int?
    let pageSize: Int
    
    let schoolId: Int
}

struct GetReviewsByMemberRequestDTO: Encodable {
    let location: CustomLocationRequestDTO
    let lastReviewId: Int?
    let pageSize: Int
    
    let memberId: Int
}

struct GetReviewsByFeedRequestDTO: Encodable {
    let lastReviewId: Int?
    let pageSize: Int
    let deviceX, deviceY: Double
}

struct CustomLocationRequestDTO: Codable {
    var x, y, deltaX, deltaY, deviceX, deviceY: Double
}
