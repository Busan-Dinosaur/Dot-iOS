//
//  MapRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import Foundation

import Moya

final class MapRepositoryImpl: MapRepository {

    private let provider = MoyaProvider<SignAPI>()
}
