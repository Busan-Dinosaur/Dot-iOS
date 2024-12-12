//
//  FindRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 1/19/24.
//

import Foundation

import Moya

final class FindRepositoryImpl: FindRepository {
    
    private let provider = MoyaProvider<ServiceAPI>()
    
    func getReviewsByFeed(request: GetReviewsByFeedRequestDTO) async throws -> ReviewByFeedDTO {
        let response = await provider.request(.getReviewsByFeed(request: request))
        return try response.decode()
    }
    
    func getStoresBySearch(request: SearchStoreRequestDTO) async throws -> StoreBySearchDTO {
        let response = await provider.request(.getStoresBySearch(request: request))
        return try response.decode()
    }
    
    func getMembersBySearch(request: SearchMemberRequestDTO) async throws -> MemberBySearchDTO {
        let response = await provider.request(.getMembersBySearch(request: request))
        return try response.decode()
    }
    
    func followMember(memberId: Int) async throws {
        let _ = await provider.request(.followMember(memberId: memberId))
    }
    
    func unfollowMember(memberId: Int) async throws {
        let _ = await provider.request(.unfollowMember(memberId: memberId))
    }
}
