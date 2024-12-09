//
//  MapCoordinator.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import UIKit

protocol MapViewModelType: BaseViewModelType {
    func presentFindViewController()
    func presentPhotoesSelectViewController()
    func presentUpdateReviewViewController(reviewId: Int)
    func presentSettingViewController()
    func presentRecommendViewController()
    func presentMemberViewController(id: Int)
    func presentStoreDetailViewController(id: Int)
    func presentReviewDetailViewController(id: Int)
    func presentBlameViewController(targetId: Int, blameTarget: String)
    func presentReviewOptionAlert(onBlame: @escaping () -> Void)
    func presentMyReviewOptionAlert(
        onUpdate: @escaping () -> Void,
        onDelete: @escaping () -> Void
    )
}

final class MapCoordinator: NSObject {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    func presentFindViewController() {
        guard let navigationController = self.navigationController else { return }
        let repository = FindRepositoryImpl()
        let usecase = FindUsecaseImpl(repository: repository)
        let viewModel = FindViewModel(usecase: usecase)
        let viewController = FindViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentPhotoesSelectViewController() {
        guard let navigationController = self.navigationController else { return }
        let coordinator = PhotoesSelectCoordinator(navigationController: navigationController)
        let viewModel = PhotoesSelectViewModel(coordinator: coordinator)
        let viewController = PhotoesSelectViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentUpdateReviewViewController(reviewId: Int) {
        guard let navigationController = self.navigationController else { return }
        let repository = UpdateReviewRepositoryImpl()
        let usecase = UpdateReviewUsecaseImpl(repository: repository)
        let coordinator = UpdateReviewCoordinator(navigationController: navigationController)
        let viewModel = UpdateReviewViewModel(usecase: usecase, coordinator: coordinator, reviewId: reviewId)
        let viewController = UpdateReviewViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentSettingViewController() {
        guard let navigationController = self.navigationController else { return }
        let repository = SettingRepositoryImpl()
        let usecase = SettingUsecaseImpl(repository: repository)
        let coordinator = SettingCoordinator(navigationController: navigationController)
        let viewModel = SettingViewModel(usecase: usecase, coordinator: coordinator)
        let viewController = SettingViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentRecommendViewController() {
        guard let navigationController = self.navigationController else { return }
        let repository = RecommendRepositoryImpl()
        let usecase = RecommendUsecaseImpl(repository: repository)
        let viewModel = RecommendViewModel(usecase: usecase)
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
    
    func presentMyReviewOptionAlert(
        onUpdate: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        guard let navigationController = self.navigationController else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "수정", style: .default) { _ in
            onUpdate()
        }
        alert.addAction(edit)
        
        let delete = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.makeRequestAlert(
                title: "삭제 여부",
                message: "정말로 삭제하시겠습니까?",
                okAction: {
                    onDelete()
                }
            )
        }
        alert.addAction(delete)
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        navigationController.present(alert, animated: true, completion: nil)
    }
}

extension MapCoordinator {
    private func makeRequestAlert(title: String, message: String, okAction: @escaping () -> Void) {
        guard let navigationController = self.navigationController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .destructive) { _ in okAction() }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        navigationController.present(alert, animated: true)
    }
}
