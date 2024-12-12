//
//  CreateReviewCoordinator.swift
//  FoodBowl
//
//  Created by Coby on 12/6/24.
//

import UIKit
import MapKit

protocol CreateReviewViewModelType: BaseViewModelType {
    func dismiss()
    func presentSearchStoreViewController(location: CLLocationCoordinate2D?)
    func presentShowWebViewController(url: String)
}

final class CreateReviewCoordinator: NSObject {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    func dismiss() {
        guard let navigationController = navigationController else { return }
        let viewControllers = navigationController.viewControllers
        let targetIndex = max(0, viewControllers.count - 3)
        let targetViewController = viewControllers[targetIndex]
        
        navigationController.popToViewController(targetViewController, animated: true)
    }
    
    func presentSearchStoreViewController(location: CLLocationCoordinate2D?) {
        guard let navigationController = navigationController else { return }
        let repository = CreateReviewRepositoryImpl()
        let usecase = CreateReviewUsecaseImpl(repository: repository)
        let viewModel = SearchStoreViewModel(usecase: usecase, location: location)
        let viewController = SearchStoreViewController(viewModel: viewModel)
        viewController.delegate = navigationController.viewControllers.last as? CreateReviewViewController
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentShowWebViewController(url: String) {
        guard let navigationController = self.navigationController else { return }
        let viewController = ShowWebViewController(url: url)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
