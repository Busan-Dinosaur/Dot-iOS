//
//  Member.swift
//  FoodBowl
//
//  Created by Coby on 1/19/24.
//

import Foundation

// MARK: - Members
struct Members: Codable {
    let content: [Member]
    let isFirst, isLast, hasNext: Bool
    let currentPage, currentSize: Int
}


// MARK: - Member
struct Member: Codable, Hashable {
    let id: Int
    let profileImageUrl: String?
    let nickname: String
    let introduction: String
    let followerCount: String
    let followingCount: String
    let isMyProfile: Bool
    var isFollowing: Bool
}
