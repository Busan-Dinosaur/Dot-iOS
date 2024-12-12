//
//  RecommendUsecase.swift
//  FoodBowl
//
//  Created by Coby on 2/18/24.
//

import Foundation

protocol RecommendUsecase {
    func getMembersByRecommend(page: Int, size: Int) async throws -> [Member]
    func followMember(memberId: Int) async throws
    func unfollowMember(memberId: Int) async throws
}

final class RecommendUsecaseImpl: RecommendUsecase {
    
    // MARK: - property
    
    private let repository: RecommendRepository
    
    // MARK: - init
    
    init(repository: RecommendRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
    
    func getMembersByRecommend(page: Int, size: Int) async throws -> [Member] {
        do {
            let membersByRecommendDTO = try await self.repository.getMembersByRecommend(page: page, size: size)
            return membersByRecommendDTO.memberSearchResponses.map { $0.toMember() }
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
}
