//
//  UpdateProfileUsecase.swift
//  FoodBowl
//
//  Created by Coby on 1/21/24.
//

import Foundation

protocol UpdateProfileUsecase {
    func getMyProfile() async throws -> Member
    func updateMemberProfile(request: UpdateMemberProfileRequestDTO) async throws
    func updateMemberProfileImage(image: Data) async throws
}

final class UpdateProfileUsecaseImpl: UpdateProfileUsecase {
    
    // MARK: - property
    
    private let repository: UpdateProfileRepository
    
    // MARK: - init
    
    init(repository: UpdateProfileRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
    
    func getMyProfile() async throws -> Member {
        do {
            let MemberProfileDTO = try await self.repository.getMyProfile()
            return MemberProfileDTO.toMember()
        } catch(let error) {
            throw error
        }
    }
    
    func updateMemberProfile(request: UpdateMemberProfileRequestDTO) async throws {
        do {
            try await self.repository.updateMemberProfile(request: request)
        } catch(let error) {
            throw error
        }
    }
    
    func updateMemberProfileImage(image: Data) async throws {
        do {
            try await self.repository.updateMemberProfileImage(image: image)
        } catch(let error) {
            throw error
        }
    }
}
