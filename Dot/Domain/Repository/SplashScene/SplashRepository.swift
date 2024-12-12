//
//  SplashRepository.swift
//  FoodBowl
//
//  Created by Coby on 12/29/23.
//

import Foundation

protocol SplashRepository {
    func patchRefreshToken(token: Token) async throws -> Token
}
