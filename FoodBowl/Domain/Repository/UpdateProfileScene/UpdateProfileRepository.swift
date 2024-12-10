//
//  UpdateProfileRepository.swift
//  FoodBowl
//
//  Created by Coby on 1/21/24.
//

import Foundation

protocol UpdateProfileRepository {
    func getMyProfile() async throws -> MemberProfileDTO
    func updateMemberProfile(request: UpdateMemberProfileRequestDTO) async throws
    func updateMemberProfileImage(image: Data) async throws
}
