//
//  RecommendCoordinator.swift
//  FoodBowl
//
//  Created by Coby on 12/10/24.
//

import UIKit

protocol RecommendViewModelType: BaseViewModelType {
    func presentMemberViewController(id: Int)
}

final class RecommendCoordinator: NSObject {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
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
}
