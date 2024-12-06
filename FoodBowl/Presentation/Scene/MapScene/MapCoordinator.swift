//
//  MapCoordinator.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import UIKit

final class MapCoordinator: NSObject {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    func presentPhotoesSelectViewController() {
        guard let navigationController = self.navigationController else { return }
        
        let viewController = PhotoesSelectViewController()
        let modalNavigationController = UINavigationController(rootViewController: viewController)
        modalNavigationController.modalPresentationStyle = .fullScreen
        
        navigationController.present(modalNavigationController, animated: true)
    }
    
    func presentRecommendViewController() {
        guard let navigationController = self.navigationController else { return }
        let repository = RecommendRepositoryImpl()
        let usecase = RecommendUsecaseImpl(repository: repository)
        let viewModel = RecommendViewModel(usecase: usecase)
        let viewController = RecommendViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentProfileViewController(id: Int) {
        guard let navigationController = self.navigationController else { return }
        let repository = ProfileRepositoryImpl()
        let usecase = ProfileUsecaseImpl(repository: repository)
        let viewModel = ProfileViewModel(
            usecase: usecase,
            memberId: id
        )
        let viewController = ProfileViewController(viewModel: viewModel)
        
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
