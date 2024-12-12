//
//  SignRepository.swift
//  FoodBowl
//
//  Created by Coby on 12/29/23.
//

import Foundation

protocol SignRepository {
    func signIn(request: SignRequestDTO) async throws -> Token
    func getMyProfile() async throws -> MemberProfileDTO
}
