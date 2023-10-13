//
//  ReviewResponse.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/12/23.
//

import Foundation

// MARK: - ReviewResponse
struct ReviewResponse: Codable {
    let errorCode: String
    let message: String
    let reviews: [Review]
    let page: Page
}

// MARK: - Page
struct Page: Codable {
    let firstId, lastID, size: Int
}

// MARK: - Review
struct Review: Codable {
    let writer: Writer
    let review: ReviewContent
    let store: StoreByReview
}

// MARK: - ReviewContent
struct ReviewContent: Codable {
    let id: Int
    let content, imagePaths, createdAt, updatedAt: String
}

// MARK: - StoreByReview
struct StoreByReview: Codable {
    let id: Int
    let categoryName, name, addressName: String
    let distance: Double
    let isBookmarked: Bool
}

// MARK: - Writer
struct Writer: Codable {
    let id: Int
    let nickname: String
    let profileImageUrl: String
    let followerCount: Int
}
