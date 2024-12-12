//
//  SettingCoordinator.swift
//  FoodBowl
//
//  Created by Coby on 12/9/24.
//

import UIKit

protocol SettingViewModelType: BaseViewModelType {
    func presentFollowerViewController()
    func presentFollowingViewController()
    func presentUpdateProfileViewController()
    func presentShowWebViewController(url: String)
}

final class SettingCoordinator: NSObject {
    
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
            memberId: id,
            isOwn: true
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
    
    func presentUpdateProfileViewController() {
        guard let navigationController = self.navigationController else { return }
        let repository = UpdateProfileRepositoryImpl()
        let usecase = UpdateProfileUsecaseImpl(repository: repository)
        let viewModel = UpdateProfileViewModel(usecase: usecase)
        let viewController = UpdateProfileViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentShowWebViewController(url: String) {
        guard let navigationController = self.navigationController else { return }
        let viewController = ShowWebViewController(url: url)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
