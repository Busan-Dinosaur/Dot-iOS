//
//  MemberRepository.swift
//  FoodBowl
//
//  Created by Coby on 12/8/24.
//

import Foundation

protocol MemberRepository {
    func getMemberProfile(id: Int) async throws -> MemberProfileDTO
    func followMember(memberId: Int) async throws
    func unfollowMember(memberId: Int) async throws
    func getReviewsByMember(request: GetReviewsByMemberRequestDTO) async throws -> ReviewDTO
    func getStoresByMember(request: GetStoresByMemberRequestDTO) async throws -> StoreDTO
    func createBookmark(storeId: Int) async throws
    func removeBookmark(storeId: Int) async throws
}
