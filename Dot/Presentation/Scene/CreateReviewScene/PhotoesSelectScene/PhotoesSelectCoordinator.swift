//
//  PhotoesSelectCoordinator.swift
//  FoodBowl
//
//  Created by Coby on 12/6/24.
//

import UIKit
import MapKit

protocol PhotoesSelectViewModelType: BaseViewModelType {
    func dismiss()
    func presentCreateReviewViewController(reviewImages: [UIImage], location: CLLocationCoordinate2D?)
}

final class PhotoesSelectCoordinator: NSObject {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    func dismiss() {
        guard let navigationController = navigationController else { return }
        navigationController.popViewController(animated: true)
    }
    
    func presentCreateReviewViewController(reviewImages: [UIImage], location: CLLocationCoordinate2D?) {
        guard let navigationController = self.navigationController else { return }
        let repository = CreateReviewRepositoryImpl()
        let usecase = CreateReviewUsecaseImpl(repository: repository)
        let coordinator = CreateReviewCoordinator(navigationController: navigationController)
        let viewModel = CreateReviewViewModel(
            usecase: usecase,
            coordinator: coordinator,
            reviewImages: reviewImages,
            location: location
        )
        let viewController = CreateReviewViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
