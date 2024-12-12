//
//  SignRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 12/29/23.
//

import Foundation

import Moya

final class SignRepositoryImpl: SignRepository {

    private let provider = MoyaProvider<SignAPI>()
    
    func signIn(request: SignRequestDTO) async throws -> Token {
        let response = await provider.request(.signIn(request: request))
        return try response.decode()
    }
    
    func getMyProfile() async throws -> MemberProfileDTO {
        let response = await provider.request(.getMyProfile)
        return try response.decode()
    }
}
