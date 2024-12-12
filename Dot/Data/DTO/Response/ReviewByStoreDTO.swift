//
//  ReviewByStoreDTO.swift
//  FoodBowl
//
//  Created by Coby on 1/17/24.
//

import Foundation

// MARK: - ReviewByStoreDTO
struct ReviewByStoreDTO: Codable {
    let reviewStoreResponse: StoreDetailDTO
    let storeReviewContentResponses: [ReviewItemByStoreDTO]
    let page: PageDTO
    
    func toReviews() -> Reviews {
        Reviews(
            store: self.reviewStoreResponse.toStore(),
            reviews: self.storeReviewContentResponses.map { $0.toReview() },
            page: self.page.toPage()
        )
    }
}

// MARK: - StoreDetailDTO
struct StoreDetailDTO: Codable {
    let id: Int
    let categoryName: String
    let name: String
    let addressName: String
    let distance: Double
    let isBookmarked: Bool
    let storeUrl: String
    
    func toStore() -> Store {
        Store(
            id: self.id,
            category: self.categoryName,
            name: self.name,
            address: self.addressName,
            isBookmarked: self.isBookmarked,
            distance: self.distance.prettyDistance,
            url: self.storeUrl,
            x: 0.0,
            y: 0.0,
            reviewCount: ""
        )
    }
}

// MARK: - ReviewItemByStoreDTO
struct ReviewItemByStoreDTO: Codable, Hashable {
    let writer: WriterItemDTO
    let review: CommentDTO
    
    static func == (lhs: ReviewItemByStoreDTO, rhs: ReviewItemByStoreDTO) -> Bool {
        lhs.review.id == rhs.review.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(review.id)
    }
    
    func toReview() -> Review {
        Review(
            member: self.writer.toMember(),
            comment: self.review.toComment(),
            store: .init(),
            thumbnail: ""
        )
    }
}
