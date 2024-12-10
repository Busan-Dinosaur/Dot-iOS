//
//  FollowRepository.swift
//  FoodBowl
//
//  Created by Coby on 1/21/24.
//

import Foundation

protocol FollowRepository {
    func getFollowingMember(memberId: Int, page: Int, size: Int) async throws -> MemberByFollowDTO
    func getFollowerMember(memberId: Int, page: Int, size: Int) async throws -> MemberByFollowDTO
    func followMember(memberId: Int) async throws
    func unfollowMember(memberId: Int) async throws
    func removeFollower(memberId: Int) async throws
}
