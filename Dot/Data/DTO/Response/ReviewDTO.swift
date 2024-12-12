//
//  ReviewDTO.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/12/23.
//

import Foundation

// MARK: - ReviewDTO
struct ReviewDTO: Codable {
    let reviews: [ReviewItemDTO]
    let page: PageDTO
    
    func toReviews() -> Reviews {
        Reviews(
            store: .init(),
            reviews: self.reviews.map { $0.toReview() },
            page: self.page.toPage()
        )
    }
}

// MARK: - PageDTO
struct PageDTO: Codable {
    let firstId, lastId: Int?
    let size: Int
    
    func toPage() -> Page {
        Page(
            firstId: self.firstId,
            lastId: self.lastId,
            size: self.size
        )
    }
}

// MARK: - ReviewItemDTO
struct ReviewItemDTO: Codable, Hashable {
    let writer: WriterItemDTO
    let review: CommentDTO
    var store: StoreByReviewDTO
    
    static func == (lhs: ReviewItemDTO, rhs: ReviewItemDTO) -> Bool {
        lhs.review.id == rhs.review.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(review.id)
    }
    
    func toReview() -> Review {
        Review(
            member: self.writer.toMember(),
            comment: self.review.toComment(),
            store: self.store.toStore(),
            thumbnail: ""
        )
    }
}

// MARK: - WriterItemDTO
struct WriterItemDTO: Codable {
    let id: Int
    let nickname: String
    let profileImageUrl: String?
    let followerCount: Int
    
    func toMember() -> Member {
        Member(
            id: self.id,
            profileImageUrl: self.profileImageUrl,
            nickname: self.nickname,
            introduction: "",
            followerCount: self.followerCount.prettyNumber,
            followingCount: "",
            isMyProfile: UserDefaultStorage.id == self.id,
            isFollowing: false
        )
    }
}

// MARK: - CommentDTO
struct CommentDTO: Codable {
    let id: Int
    let content: String
    let imagePaths: [String]
    let createdAt: String
    let updatedAt: String
    
    func toComment() -> Comment {
        Comment(
            id: self.id,
            content: self.content,
            imagePaths: self.imagePaths,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

// MARK: - StoreByReviewDTO
struct StoreByReviewDTO: Codable {
    let id: Int
    let categoryName, name, addressName: String
    let distance: Double
    var isBookmarked: Bool
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
