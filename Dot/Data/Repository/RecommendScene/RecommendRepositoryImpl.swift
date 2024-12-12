//
//  RecommendRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 2/18/24.
//

import Foundation

import Moya

final class RecommendRepositoryImpl: RecommendRepository {
    
    private let provider = MoyaProvider<ServiceAPI>()
    
    func getMembersByRecommend(page: Int, size: Int) async throws -> MemberBySearchDTO {
        let response = await provider.request(.getRecommendMember(page: page, size: size))
        return try response.decode()
    }
    
    func followMember(memberId: Int) async throws {
        let _ = await provider.request(.followMember(memberId: memberId))
    }
    
    func unfollowMember(memberId: Int) async throws {
        let _ = await provider.request(.unfollowMember(memberId: memberId))
    }
}
