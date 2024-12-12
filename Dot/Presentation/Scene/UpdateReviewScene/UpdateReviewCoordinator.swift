//
//  UpdateReviewCoordinator.swift
//  FoodBowl
//
//  Created by Coby on 12/6/24.
//

import UIKit
import MapKit

protocol UpdateReviewViewModelType: BaseViewModelType {
    func dismiss()
    func presentShowWebViewController(url: String)
}

final class UpdateReviewCoordinator: NSObject {
    
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    func dismiss() {
        guard let navigationController = navigationController else { return }
        navigationController.popViewController(animated: true)
    }
    
    func presentShowWebViewController(url: String) {
        guard let navigationController = self.navigationController else { return }
        let viewController = ShowWebViewController(url: url)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
