//
//  BlameRepository.swift
//  FoodBowl
//
//  Created by Coby on 1/4/24.
//

import Foundation

protocol BlameRepository {
    func createBlame(request: CreateBlameRequestDTO) async throws
}
