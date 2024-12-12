//
//  CreateReviewRepositoryImpl.swift
//  FoodBowl
//
//  Created by Coby on 1/18/24.
//

import Foundation

import Moya

final class CreateReviewRepositoryImpl: CreateReviewRepository {

    private let providerKakao = MoyaProvider<KakaoAPI>()
    private let provider = MoyaProvider<ServiceAPI>()
    
    func searchStores(x: String, y: String, keyword: String) async throws -> PlaceDTO {
        let response = await providerKakao.request(.searchStores(x: x, y: y, keyword: keyword))
        return try response.decode()
    }
    
    func searchUniv(x: String, y: String) async throws -> PlaceDTO {
        let response = await providerKakao.request(.searchUniv(x: x, y: y))
        return try response.decode()
    }
    
    func createReview(request: CreateReviewRequestDTO, images: [Data]) async throws {
        let _ = await provider.request(.createReview(request: request, images: images))
    }
    
    func searchStoresByLocation(x: String, y: String) async throws -> PlaceDTO {
        let response = await providerKakao.request(.searchStoresByLocation(x: x, y: y))
        return try response.decode()
    }
}
