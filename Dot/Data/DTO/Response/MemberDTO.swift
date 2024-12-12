//
//  MemberDTO.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/12/23.
//

import Foundation

// MARK: - MemberDTO
struct MemberDTO: Codable {
    let memberId: Int
    let nickname: String
    let profileImageUrl: String?
    let followerCount: Int
    let isFollowing, isMe: Bool
    
    func toMember() -> Member {
        Member(
            id: self.memberId,
            profileImageUrl: self.profileImageUrl,
            nickname: self.nickname,
            introduction: "",
            followerCount: self.followerCount.prettyNumber,
            followingCount: "",
            isMyProfile: self.isMe,
            isFollowing: self.isFollowing
        )
    }
}

// MARK: - MemberBySearchDTO
struct MemberBySearchDTO: Codable {
    let memberSearchResponses: [MemberDTO]
}

// MARK: - MemberProfileDTO
struct MemberProfileDTO: Codable {
    let id: Int
    var profileImageUrl: String?
    var nickname: String
    var introduction: String?
    let followerCount: Int
    let followingCount: Int
    let isMyProfile: Bool
    let isFollowing: Bool
    
    func toMember() -> Member {
        Member(
            id: self.id,
            profileImageUrl: self.profileImageUrl,
            nickname: self.nickname,
            introduction: self.introduction ?? "",
            followerCount: self.followerCount.prettyNumber,
            followingCount: self.followingCount.prettyNumber,
            isMyProfile: self.isMyProfile,
            isFollowing: self.isFollowing
        )
    }
}

// MARK: - MemberByFollowDTO
struct MemberByFollowDTO: Codable {
    let content: [MemberByFollowItemDTO]
    let isFirst, isLast, hasNext: Bool
    let currentPage, currentSize: Int
    
    func toMembers() -> Members {
        Members(
            content: self.content.map { $0.toMember() },
            isFirst: self.isFirst,
            isLast: self.isLast,
            hasNext: self.hasNext,
            currentPage: self.currentPage,
            currentSize: self.currentSize
        )
    }
}

// MARK: - MemberByFollowItemDTO
struct MemberByFollowItemDTO: Codable, Hashable {
    let memberId: Int
    let profileImageUrl: String?
    let nickname: String
    let followerCount: Int
    let isMe: Bool
    var isFollowing: Bool
    
    func toMember() -> Member {
        Member(
            id: self.memberId,
            profileImageUrl: self.profileImageUrl,
            nickname: self.nickname,
            introduction: "",
            followerCount: self.followerCount.prettyNumber,
            followingCount: "",
            isMyProfile: self.isMe,
            isFollowing: self.isFollowing
        )
    }
}
