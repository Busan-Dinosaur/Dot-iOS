//
//  ReviewDetailCoordinator.swift
//  FoodBowl
//
//  Created by Coby on 12/10/24.
//

import UIKit

protocol ReviewDetailViewModelType: BaseViewModelType {
    func dismiss()
    func presentMemberViewController()
    func presentStoreDetailViewController()
    func presentShowWebViewController(url: String)
    func presentUpdateReviewViewController()
    func presentBlameViewController()
    func presentOptionAlert(
        onBlame: @escaping () -> Void,
        onUpdate: @escaping () -> Void,
        onDelete: @escaping () -> Void
    )
    func presentReviewOptionAlert(onBlame: @escaping () -> Void)
    func presentMyReviewOptionAlert(
        onUpdate: @escaping () -> Void,
        onDelete: @escaping () -> Void
    )
}

final class ReviewDetailCoordinator: NSObject {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    func dismiss() {
        guard let navigationController = navigationController else { return }
        navigationController.popViewController(animated: true)
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
    
    func presentShowWebViewController(url: String) {
        guard let navigationController = self.navigationController else { return }
        let viewController = ShowWebViewController(url: url)
        
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

extension ReviewDetailCoordinator {
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
