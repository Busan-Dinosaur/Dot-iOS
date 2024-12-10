//
//  MemberUsecase.swift
//  FoodBowl
//
//  Created by Coby on 12/8/24.
//

import Foundation

protocol MemberUsecase {
    func getMemberProfile(id: Int) async throws -> Member
    func followMember(memberId: Int) async throws
    func unfollowMember(memberId: Int) async throws
    func getReviewsByMember(request: GetReviewsByMemberRequestDTO) async throws -> Reviews
    func getStoresByMember(request: GetStoresByMemberRequestDTO) async throws -> [Store]
    func createBookmark(storeId: Int) async throws
    func removeBookmark(storeId: Int) async throws
}

final class MemberUsecaseImpl: MemberUsecase {
    
    // MARK: - property
    
    private let repository: MemberRepository
    
    // MARK: - init
    
    init(repository: MemberRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
    
    func getMemberProfile(id: Int) async throws -> Member {
        do {
            let MemberProfileDTO = try await self.repository.getMemberProfile(id: id)
            return MemberProfileDTO.toMember()
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
    
    func getReviewsByMember(request: GetReviewsByMemberRequestDTO) async throws -> Reviews {
        do {
            let reviewDTO = try await self.repository.getReviewsByMember(request: request)
            return reviewDTO.toReviews()
        } catch(let error) {
            throw error
        }
    }
    
    func getStoresByMember(request: GetStoresByMemberRequestDTO) async throws -> [Store] {
        do {
            let storeDTO = try await self.repository.getStoresByMember(request: request)
            return storeDTO.stores.map { $0.toStore() }
        } catch(let error) {
            throw error
        }
    }
    
    func createBookmark(storeId: Int) async throws {
        do {
            try await self.repository.createBookmark(storeId: storeId)
        } catch(let error) {
            throw error
        }
    }
    
    func removeBookmark(storeId: Int) async throws {
        do {
            try await self.repository.removeBookmark(storeId: storeId)
        } catch(let error) {
            throw error
        }
    }
}
