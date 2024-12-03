//
//  SceneDelegate.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    typealias Task = _Concurrency.Task
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)

        LocationManager.shared.checkLocationService()
        
//        self.window?.rootViewController = self.splashViewController
        self.window?.rootViewController = self.mapViewController
        self.window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

extension SceneDelegate {
    
    private var splashViewController: UINavigationController {
        let navigationController = UINavigationController()
        let repository = SplashRepositoryImpl()
        let usecase = SplashUsecaseImpl(repository: repository)
        let coordinator = SplashCoordinator(navigationController: navigationController)
        let viewModel = SplashViewModel(usecase: usecase, coordinator: coordinator)
        let viewController = SplashViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        return navigationController
    }
    
    private var signViewController: UINavigationController {
        let navigationController = UINavigationController()
        let repository = SignRepositoryImpl()
        let usecase = SignUsecaseImpl(repository: repository)
        let coordinator = SignCoordinator(navigationController: navigationController)
        let viewModel = SignViewModel(usecase: usecase, coordinator: coordinator)
        let viewController = SignViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        return navigationController
    }
    
    private var mapViewController: UINavigationController {
        let navigationController = UINavigationController()
        let repository = MapRepositoryImpl()
        let usecase = MapUsecaseImpl(repository: repository)
        let coordinator = MapCoordinator(navigationController: navigationController)
        let viewModel = MapViewModel(usecase: usecase, coordinator: coordinator)
        let viewController = MapViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        return navigationController
    }
    
    func moveToSignViewController() {
        self.window?.rootViewController = self.signViewController
    }
    
    func moveToTabViewController() {
        self.window?.rootViewController = TabBarController()
    }
}
