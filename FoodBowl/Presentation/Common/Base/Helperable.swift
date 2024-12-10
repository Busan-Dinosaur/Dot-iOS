//
//  Helperable.swift
//  FoodBowl
//
//  Created by Coby on 1/25/24.
//

import UIKit
import MapKit

protocol Helperable {
    func presentMemberViewController(id: Int)
    func presentUpdateProfileViewController()
    func presentStoreDetailViewController(id: Int)
    func presentReviewDetailViewController(id: Int)
    func presentPhotoesSelectViewController()
    func presentCreateReviewViewController(reviewImages: [UIImage], location: CLLocationCoordinate2D?)
    func presentUpdateReviewViewController(id: Int)
    func presentSearchStoreViewController(location: CLLocationCoordinate2D?)
    func presentFollowerViewController(id: Int, isOwn: Bool)
    func presentFollowingViewController(id: Int, isOwn: Bool)
    func presentShowWebViewController(url: String)
    func presentRecommendViewController()
}

extension Helperable where Self: UIViewController {
    func presentMemberViewController(id: Int) {
//        let repository = ProfileRepositoryImpl()
//        let usecase = ProfileUsecaseImpl(repository: repository)
//        let viewModel = ProfileViewModel(
//            usecase: usecase,
//            memberId: id
//        )
//        let viewController = ProfileViewController(viewModel: viewModel)
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.navigationController?.pushViewController(viewController, animated: true)
//        }
    }
    
    func presentUpdateProfileViewController() {
        let repository = UpdateProfileRepositoryImpl()
        let usecase = UpdateProfileUsecaseImpl(repository: repository)
        let viewModel = UpdateProfileViewModel(usecase: usecase)
        let viewController = UpdateProfileViewController(viewModel: viewModel)
        
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func presentStoreDetailViewController(id: Int) {
//        let repository = StoreDetailRepositoryImpl()
//        let usecase = StoreDetailUsecaseImpl(repository: repository)
//        let viewModel = StoreDetailViewModel(
//            usecase: usecase,
//            storeId: id
//        )
//        let viewController = StoreDetailViewController(viewModel: viewModel)
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.navigationController?.pushViewController(viewController, animated: true)
//        }
    }
    
    func presentReviewDetailViewController(id: Int) {
//        let repository = ReviewDetailRepositoryImpl()
//        let usecase = ReviewDetailUsecaseImpl(repository: repository)
//        let viewModel = ReviewDetailViewModel(
//            usecase: usecase,
//            reviewId: id
//        )
//        let viewController = ReviewDetailViewController(viewModel: viewModel)
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.navigationController?.pushViewController(viewController, animated: true)
//        }
    }
    
    func presentPhotoesSelectViewController() {
//        let viewController = PhotoesSelectViewController()
//        let navigationController = UINavigationController(rootViewController: viewController)
//        navigationController.modalPresentationStyle = .fullScreen
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.present(navigationController, animated: true)
//        }
    }
    
    func presentCreateReviewViewController(reviewImages: [UIImage], location: CLLocationCoordinate2D?) {
//        let repository = CreateReviewRepositoryImpl()
//        let usecase = CreateReviewUsecaseImpl(repository: repository)
//        let viewModel = CreateReviewViewModel(
//            usecase: usecase,
//            reviewImages: reviewImages,
//            location: location
//        )
//        let viewController = CreateReviewViewController(viewModel: viewModel)
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.navigationController?.pushViewController(viewController, animated: true)
//        }
    }
    
    func presentUpdateReviewViewController(id: Int) {
//        let repository = UpdateReviewRepositoryImpl()
//        let usecase = UpdateReviewUsecaseImpl(repository: repository)
//        let viewModel = UpdateReviewViewModel(
//            usecase: usecase,
//            reviewId: id
//        )
//        let viewController = UpdateReviewViewController(viewModel: viewModel)
//        let navigationController = UINavigationController(rootViewController: viewController)
//        navigationController.modalPresentationStyle = .fullScreen
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.present(navigationController, animated: true)
//        }
    }
    
    func presentSearchStoreViewController(location: CLLocationCoordinate2D?) {
        let repository = CreateReviewRepositoryImpl()
        let usecase = CreateReviewUsecaseImpl(repository: repository)
        let viewModel = SearchStoreViewModel(usecase: usecase, location: location)
        let viewController = SearchStoreViewController(viewModel: viewModel)
        viewController.delegate = self as? any SearchStoreViewControllerDelegate
        
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func presentFollowerViewController(id: Int, isOwn: Bool) {
//        let repository = FollowRepositoryImpl()
//        let usecase = FollowUsecaseImpl(repository: repository)
//        let viewModel = FollowerViewModel(
//            usecase: usecase,
//            memberId: id,
//            isOwn: isOwn
//        )
//        let viewController = FollowerViewController(viewModel: viewModel)
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.navigationController?.pushViewController(viewController, animated: true)
//        }
    }
    
    func presentFollowingViewController(id: Int, isOwn: Bool) {
//        let repository = FollowRepositoryImpl()
//        let usecase = FollowUsecaseImpl(repository: repository)
//        let coordinator = FollowCoordinator(navigationController: navigationController)
//        let viewModel = FollowingViewModel(
//            usecase: usecase,
//            coordinator: coordinator
//            memberId: id,
//            isOwn: isOwn
//        )
//        let viewController = FollowingViewController(viewModel: viewModel)
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.navigationController?.pushViewController(viewController, animated: true)
//        }
    }
    
    func presentShowWebViewController(url: String) {
        let showWebViewController = ShowWebViewController(url: url)
        let navigationController = UINavigationController(rootViewController: showWebViewController)
        
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.present(navigationController, animated: true)
        }
    }
    
    func presentSettingViewController() {
//        let repository = SettingRepositoryImpl()
//        let usecase = SettingUsecaseImpl(repository: repository)
//        let viewModel = SettingViewModel(usecase: usecase)
//        let viewController = SettingViewController(viewModel: viewModel)
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.navigationController?.pushViewController(viewController, animated: true)
//        }
    }
    
    func presentRecommendViewController() {
//        let repository = RecommendRepositoryImpl()
//        let usecase = RecommendUsecaseImpl(repository: repository)
//        let viewModel = RecommendViewModel(usecase: usecase)
//        let viewController = RecommendViewController(viewModel: viewModel)
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.navigationController?.pushViewController(viewController, animated: true)
//        }
    }
}
