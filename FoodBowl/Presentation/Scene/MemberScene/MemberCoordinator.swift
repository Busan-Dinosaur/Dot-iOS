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
    func presentMemberBlameViewController()
    func presentBlameViewController(targetId: Int, blameTarget: String)
    func presentReviewOptionAlert(onBlame: @escaping () -> Void)
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
        let coordinator = FollowCoordinator(navigationController: navigationController)
        let viewModel = FollowerViewModel(
            usecase: usecase,
            coordinator: coordinator,
            memberId: id
        )
        let viewController = FollowerViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentFollowingViewController(id: Int) {
        guard let navigationController = self.navigationController else { return }
        let repository = FollowRepositoryImpl()
        let usecase = FollowUsecaseImpl(repository: repository)
        let coordinator = FollowCoordinator(navigationController: navigationController)
        let viewModel = FollowingViewModel(
            usecase: usecase,
            coordinator: coordinator,
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
        let coordinator = ReviewDetailCoordinator(navigationController: navigationController)
        let viewModel = ReviewDetailViewModel(
            usecase: usecase,
            coordinator: coordinator,
            reviewId: id
        )
        let viewController = ReviewDetailViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentBlameViewController(targetId: Int, blameTarget: String) {
        guard let navigationController = self.navigationController else { return }
        let repository = BlameRepositoryImpl()
        let usecase = BlameUsecaseImpl(repository: repository)
        let viewModel = BlameViewModel(usecase: usecase, targetId: targetId, blameTarget: blameTarget)
        let viewController = BlameViewController(viewModel: viewModel)
        
        let modalViewController = UINavigationController(rootViewController: viewController)
        modalViewController.modalPresentationStyle = .fullScreen
        
        navigationController.present(modalViewController, animated: true)
    }
    
    func presentReviewOptionAlert(onBlame: @escaping () -> Void) {
        guard let navigationController = self.navigationController else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let report = UIAlertAction(title: "신고", style: .destructive, handler: { _ in
            onBlame()
        })
        alert.addAction(report)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        navigationController.present(alert, animated: true, completion: nil)
    }
}
