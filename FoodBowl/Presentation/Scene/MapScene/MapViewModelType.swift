//
//  MapViewModelType.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import Foundation

protocol MapViewModelType: BaseViewModelType {
    func presentPhotoesSelectViewController()
    func presentRecommendViewController()
    func presentProfileViewController(id: Int)
    func presentStoreDetailViewController(id: Int)
    func presentReviewDetailViewController(id: Int)
}
