//
//  FollowRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 1/21/24.
//

import Foundation

import Moya

final class FollowRepositoryImpl: FollowRepository {
    
    private let provider = MoyaProvider<ServiceAPI>()
    
    func getFollowingMember(memberId: Int, page: Int, size: Int) async throws -> MemberByFollowDTO {
        let response = await provider.request(.getFollowingMember(memberId: memberId, page: page, size: size))
        return try response.decode()
    }
    
    func getFollowerMember(memberId: Int, page: Int, size: Int) async throws -> MemberByFollowDTO {
        let response = await provider.request(.getFollowerMember(memberId: memberId, page: page, size: size))
        return try response.decode()
    }
    
    func followMember(memberId: Int) async throws {
        let _ = await provider.request(.followMember(memberId: memberId))
    }
    
    func unfollowMember(memberId: Int) async throws {
        let _ = await provider.request(.unfollowMember(memberId: memberId))
    }
    
    func removeFollower(memberId: Int) async throws {
        let _ = await provider.request(.removeFollower(memberId: memberId))
    }
}
