//
//  FindUsecase.swift
//  FoodBowl
//
//  Created by Coby on 1/19/24.
//

import Foundation

protocol FindUsecase {
    func getReviewsByFeed(request: GetReviewsByFeedRequestDTO) async throws -> Reviews
    func getStoresBySearch(request: SearchStoreRequestDTO) async throws -> [Store]
    func getMembersBySearch(request: SearchMemberRequestDTO) async throws -> [Member]
    func followMember(memberId: Int) async throws
    func unfollowMember(memberId: Int) async throws
}

final class FindUsecaseImpl: FindUsecase {
    
    // MARK: - property
    
    private let repository: FindRepository
    
    // MARK: - init
    
    init(repository: FindRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
    
    func getReviewsByFeed(request: GetReviewsByFeedRequestDTO) async throws -> Reviews {
        do {
            let reviewByFeedDTO = try await self.repository.getReviewsByFeed(request: request)
            return reviewByFeedDTO.toReviews()
        } catch(let error) {
            throw error
        }
    }
    
    func getStoresBySearch(request: SearchStoreRequestDTO) async throws -> [Store] {
        do {
            let storesBySearchDTO = try await self.repository.getStoresBySearch(request: request)
            return storesBySearchDTO.searchResponses.map { $0.toStore() }
        } catch(let error) {
            throw error
        }
    }
    
    func getMembersBySearch(request: SearchMemberRequestDTO) async throws -> [Member] {
        do {
            let membersBySearchDTO = try await self.repository.getMembersBySearch(request: request)
            return membersBySearchDTO.memberSearchResponses.map { $0.toMember() }
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
