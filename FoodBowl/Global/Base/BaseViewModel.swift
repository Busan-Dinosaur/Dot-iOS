//
//  BaseViewModel.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/16/23.
//

import UIKit

import Moya

class BaseViewModel {
    let pageSize = 10
    let size = 10

    let providerService = MoyaProvider<ServiceAPI>()
    let providerReview = MoyaProvider<ReviewAPI>()
    let providerStore = MoyaProvider<StoreAPI>()
    let providerMember = MoyaProvider<MemberAPI>()
    let providerFollow = MoyaProvider<FollowAPI>()
}

// MARK: - Review and Bookmark Method
extension BaseViewModel {
    func removeReview(id: Int) async -> Bool {
        let response = await providerReview.request(.removeReview(id: id))
        switch response {
        case .success:
            return true
        case .failure(let err):
            handleError(err)
            return false
        }
    }

    func createBookmark(storeId: Int) async -> Bool {
        let response = await providerStore.request(.createBookmark(storeId: storeId))
        switch response {
        case .success:
            return true
        case .failure(let err):
            handleError(err)
            return false
        }
    }

    func removeBookmark(storeId: Int) async -> Bool {
        let response = await providerStore.request(.removeBookmark(storeId: storeId))
        switch response {
        case .success:
            return false
        case .failure(let err):
            handleError(err)
            return true
        }
    }
}

// MARK: - Follow Method
extension BaseViewModel {
    func followMember(memberId: Int) async -> Bool {
        let response = await providerFollow.request(.followMember(memberId: memberId))
        switch response {
        case .success:
            return true
        case .failure(let err):
            handleError(err)
            return false
        }
    }

    func unfollowMember(memberId: Int) async -> Bool {
        let response = await providerFollow.request(.unfollowMember(memberId: memberId))
        switch response {
        case .success:
            return false
        case .failure(let err):
            handleError(err)
            return true
        }
    }
}

extension BaseViewModel {
    func handleError(_ error: MoyaError) {
        if let errorResponse = error.errorResponse {
            print("에러 코드: \(errorResponse.errorCode)")
            print("에러 메시지: \(errorResponse.message)")
        } else {
            print("네트워크 에러: \(error.localizedDescription)")
        }
    }
}
