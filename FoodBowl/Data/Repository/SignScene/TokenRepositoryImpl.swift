//
//  TokenRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 12/29/23.
//

import Foundation

import Moya

final class TokenRepositoryImpl: TokenRepository {

    private let provider = MoyaProvider<ServiceAPI>()

    func patchRefreshToken(token: TokenDTO) async throws -> TokenDTO {
        let response = await provider.request(.patchRefreshToken(token: token))
        return try response.decode()
    }
}