//
//  MemberCoordinator.swift
//  FoodBowl
//
//  Created by Coby on 12/8/24.
//

import UIKit

protocol MemberViewModelType: BaseViewModelType {
    func presentFollowerViewController()
    func presentFollowingViewController()
    func presentMemberViewController(id: Int)
    func presentStoreDetailViewController(id: Int)
    func presentReviewDetailViewController(id: Int)
}

final class MemberCoordinator: NSObject {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    func presentFollowerViewController(id: Int) {
        guard let navigationController = self.navigationController else { return }
        let repository = FollowRepositoryImpl()
        let usecase = FollowUsecaseImpl(repository: repository)
        let viewModel = FollowerViewModel(
            usecase: usecase,
            memberId: id
        )
        let viewController = FollowerViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentFollowingViewController(id: Int) {
        guard let navigationController = self.navigationController else { return }
        let repository = FollowRepositoryImpl()
        let usecase = FollowUsecaseImpl(repository: repository)
        let viewModel = FollowingViewModel(
            usecase: usecase,
            memberId: id
        )
        let viewController = FollowingViewController(viewModel: viewModel)
        
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
        let viewModel = StoreDetailViewModel(
            usecase: usecase,
            storeId: id
        )
        let viewController = StoreDetailViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentReviewDetailViewController(id: Int) {
        guard let navigationController = self.navigationController else { return }
        let repository = ReviewDetailRepositoryImpl()
        let usecase = ReviewDetailUsecaseImpl(repository: repository)
        let viewModel = ReviewDetailViewModel(
            usecase: usecase,
            reviewId: id
        )
        let viewController = ReviewDetailViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
