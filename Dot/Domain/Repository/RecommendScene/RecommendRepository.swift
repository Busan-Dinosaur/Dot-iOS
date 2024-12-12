//
//  RecommendRepository.swift
//  FoodBowl
//
//  Created by Coby on 2/18/24.
//

import Foundation

protocol RecommendRepository {
    func getMembersByRecommend(page: Int, size: Int) async throws -> MemberBySearchDTO
    func followMember(memberId: Int) async throws
    func unfollowMember(memberId: Int) async throws
}
