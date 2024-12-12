//
//  BlameRepositroyImpl.swift
//  FoodBowl
//
//  Created by Coby on 1/4/24.
//

import Foundation

import Moya

final class BlameRepositoryImpl: BlameRepository {

    private let provider = MoyaProvider<ServiceAPI>()
    
    func createBlame(request: CreateBlameRequestDTO) async throws {
        let _ = await provider.request(.createBlame(request: request))
    }
}
