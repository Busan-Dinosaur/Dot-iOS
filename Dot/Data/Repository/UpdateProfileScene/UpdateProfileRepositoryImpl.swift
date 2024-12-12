//
//  UpdateProfileRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 1/21/24.
//

import Foundation

import Moya

final class UpdateProfileRepositoryImpl: UpdateProfileRepository {
    
    private let provider = MoyaProvider<ServiceAPI>()
    private let providerSign = MoyaProvider<SignAPI>()
    
    func getMyProfile() async throws -> MemberProfileDTO {
        let response = await providerSign.request(.getMyProfile)
        return try response.decode()
    }
    
    func updateMemberProfile(request: UpdateMemberProfileRequestDTO) async throws {
        let _ = await provider.request(.updateMemberProfile(request: request))
    }
    
    func updateMemberProfileImage(image: Data) async throws {
        let _ = await provider.request(.updateMemberProfileImage(image: image))
    }
}
