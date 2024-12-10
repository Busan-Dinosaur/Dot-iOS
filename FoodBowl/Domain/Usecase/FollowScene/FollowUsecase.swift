//
//  FollowUsecase.swift
//  FoodBowl
//
//  Created by Coby on 1/21/24.
//

import Foundation

protocol FollowUsecase {
    func getFollowingMember(memberId: Int, page: Int, size: Int) async throws -> Members
    func getFollowerMember(memberId: Int, page: Int, size: Int) async throws -> Members
    func followMember(memberId: Int) async throws
    func unfollowMember(memberId: Int) async throws
    func removeFollower(memberId: Int) async throws
}

final class FollowUsecaseImpl: FollowUsecase {
    
    // MARK: - property
    
    private let repository: FollowRepository
    
    // MARK: - init
    
    init(repository: FollowRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
    
    func getFollowingMember(memberId: Int, page: Int, size: Int) async throws -> Members {
        do {
            let memberByFollowDTO = try await self.repository.getFollowingMember(memberId: memberId, page: page, size: size)
            return memberByFollowDTO.toMembers()
        } catch(let error) {
            throw error
        }
    }
    
    func getFollowerMember(memberId: Int, page: Int, size: Int) async throws -> Members {
        do {
            let memberByFollowDTO = try await self.repository.getFollowerMember(memberId: memberId, page: page, size: size)
            return memberByFollowDTO.toMembers()
        } catch(let error) {
            throw error
        }
    }
    
    func followMember(memberId: Int) async throws {
        do {
            try await self.repository.followMember(memberId: memberId)
        } catch(let error) {
            throw error
        }
    }
    
    func unfollowMember(memberId: Int) async throws {
        do {
            try await self.repository.unfollowMember(memberId: memberId)
        } catch(let error) {
            throw error
        }
    }
    
    func removeFollower(memberId: Int) async throws {
        do {
            try await self.repository.removeFollower(memberId: memberId)
        } catch(let error) {
            throw error
        }
    }
}
