//
//  SplashRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 12/29/23.
//

import Foundation

import Moya

final class SplashRepositoryImpl: SplashRepository {

    private let provider = MoyaProvider<SignAPI>()

    func patchRefreshToken(token: Token) async throws -> Token {
        let response = await provider.request(.patchRefreshToken(token: token))
        return try response.decode()
    }
}
