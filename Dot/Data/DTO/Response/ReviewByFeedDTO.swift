//
//  ReviewByFeedDTO.swift
//  FoodBowl
//
//  Created by Coby on 1/19/24.
//

import Foundation

// MARK: - ReviewByFeedDTO
struct ReviewByFeedDTO: Codable {
    let reviewFeedResponses: [ReviewItemByFeedDTO]
    let reviewPageInfo: PageDTO
    
    func toReviews() -> Reviews {
        Reviews(
            store: .init(),
            reviews: self.reviewFeedResponses.map { $0.toReview() },
            page: self.reviewPageInfo.toPage()
        )
    }
}

// MARK: - ReviewItemByFeedDTO
struct ReviewItemByFeedDTO: Codable {
    let reviewFeedThumbnail: String
    let writer: WriterItemDTO
    let review: CommentDTO
    let store: StoreByReviewDTO
    
    func toReview() -> Review {
        Review(
            member: self.writer.toMember(),
            comment: self.review.toComment(),
            store: self.store.toStore(),
            thumbnail: self.reviewFeedThumbnail
        )
    }
}
