//
//  FindCoordinator.swift
//  FoodBowl
//
//  Created by Coby on 12/10/24.
//

import UIKit

protocol FindViewModelType: BaseViewModelType {
    func presentRecommendViewController()
    func presentMemberViewController(id: Int)
    func presentStoreDetailViewController(id: Int)
    func presentReviewDetailViewController(id: Int)
}

final class FindCoordinator: NSObject {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    func presentRecommendViewController() {
        guard let navigationController = self.navigationController else { return }
        let repository = RecommendRepositoryImpl()
        let usecase = RecommendUsecaseImpl(repository: repository)
        let coordinator = RecommendCoordinator(navigationController: navigationController)
        let viewModel = RecommendViewModel(usecase: usecase, coordinator: coordinator)
        let viewController = RecommendViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentMemberViewController(id: Int) {
        guard let navigationController = self.navigationController else { return }
        let repository = MemberRepositoryImpl()
        let usecase = MemberUsecaseImpl(repository: repository)
        let coordinator = MemberCoordinator(navigationController: navigationController)
        let viewModel = MemberViewModel(
            usecase: usecase,
            coordinator: coordinator,
            memberId: id
        )
        let viewController = MemberViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentStoreDetailViewController(id: Int) {
        guard let navigationController = self.navigationController else { return }
        let repository = StoreDetailRepositoryImpl()
        let usecase = StoreDetailUsecaseImpl(repository: repository)
        let coordinator = StoreDetailCoordinator(navigationController: navigationController)
        let viewModel = StoreDetailViewModel(
            usecase: usecase,
            coordinator: coordinator,
            storeId: id
        )
        let viewController = StoreDetailViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentReviewDetailViewController(id: Int) {
        guard let navigationController = self.navigationController else { return }
        let repository = ReviewDetailRepositoryImpl()
        let usecase = ReviewDetailUsecaseImpl(repository: repository)
        let coordinator = ReviewDetailCoordinator(navigationController: navigationController)
        let viewModel = ReviewDetailViewModel(
            usecase: usecase,
            coordinator: coordinator,
            reviewId: id
        )
        let viewController = ReviewDetailViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
