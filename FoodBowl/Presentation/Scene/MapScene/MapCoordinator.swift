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
}
