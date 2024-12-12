//
//  Reviews.swift
//  FoodBowl
//
//  Created by Coby on 1/17/24.
//

import Foundation

// MARK: - Reviews
struct Reviews: Codable {
    let store: Store
    let reviews: [Review]
    let page: Page
}

// MARK: - Page
struct Page: Codable {
    let firstId, lastId: Int?
    let size: Int
}

// MARK: - Review
struct Review: Codable, Hashable {
    let member: Member
    let comment: Comment
    var store: Store
    let thumbnail: String
    
    static func == (lhs: Review, rhs: Review) -> Bool {
        lhs.comment.id == rhs.comment.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(comment.id)
    }
}

// MARK: - Comment
struct Comment: Codable {
    let id: Int
    let content: String
    let imagePaths: [String]
    let createdAt: String
    let updatedAt: String
}
