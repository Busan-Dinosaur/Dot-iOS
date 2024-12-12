//
//  FindRepository.swift
//  FoodBowl
//
//  Created by Coby on 1/19/24.
//

import Foundation

protocol FindRepository {
    func getReviewsByFeed(request: GetReviewsByFeedRequestDTO) async throws -> ReviewByFeedDTO
    func getStoresBySearch(request: SearchStoreRequestDTO) async throws -> StoreBySearchDTO
    func getMembersBySearch(request: SearchMemberRequestDTO) async throws -> MemberBySearchDTO
    func followMember(memberId: Int) async throws
    func unfollowMember(memberId: Int) async throws
}
