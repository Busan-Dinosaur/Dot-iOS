//
//  TabBarController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import UIKit

final class TabBarController: UITabBarController {
    private lazy var vc1 = UINavigationController(rootViewController: self.friendViewController)
    private lazy var vc2 = UINavigationController(rootViewController: self.findViewController)
    private lazy var vc3 = UINavigationController(rootViewController: self.myPlaceViewController)
    private lazy var vc4 = UINavigationController(rootViewController: self.profileViewController)

    override func viewDidLoad() {
        super.viewDidLoad()

        vc1.tabBarItem.image = ImageLiteral.friends
            .resize(to: CGSize(width: 20, height: 20))
        vc1.tabBarItem.title = "친구들"

        vc2.tabBarItem.image = ImageLiteral.search
            .resize(to: CGSize(width: 18, height: 18))
        vc2.tabBarItem.title = "둘러보기"

        vc3.tabBarItem.image = ImageLiteral.place
            .resize(to: CGSize(width: 20, height: 20))
        vc3.tabBarItem.title = "내장소"

        vc4.tabBarItem.image = ImageLiteral.profile
            .resize(to: CGSize(width: 20, height: 20))
        vc4.tabBarItem.title = "프로필"

        tabBar.tintColor = .mainColor
        tabBar.backgroundColor = .mainBackgroundColor
        setViewControllers([vc1, vc2, vc3, vc4], animated: true)

        let tabBarAppearance: UITabBarAppearance = .init()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = .mainBackgroundColor
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension TabBarController {
    var friendViewController: FriendViewController {
        let repository = FriendRepositoryImpl()
        let usecase = FriendUsecaseImpl(repository: repository)
        let viewModel = FriendViewModel(usecase: usecase)
        let viewController = FriendViewController(viewModel: viewModel)
        return viewController
    }
    
    var findViewController: FindViewController {
        let repository = FindRepositoryImpl()
        let usecase = FindUsecaseImpl(repository: repository)
        let viewModel = FindViewModel(usecase: usecase)
        let viewController = FindViewController(viewModel: viewModel)
        return viewController
    }
    
    var myPlaceViewController: MyPlaceViewController {
        let repository = MyPlaceRepositoryImpl()
        let usecase = MyPlaceUsecaseImpl(repository: repository)
        let viewModel = MyPlaceViewModel(usecase: usecase)
        let viewController = MyPlaceViewController(viewModel: viewModel)
        return viewController
    }
    
    var profileViewController: ProfileViewController {
        let repository = ProfileRepositoryImpl()
        let usecase = ProfileUsecaseImpl(repository: repository)
        let viewModel = ProfileViewModel(
            usecase: usecase,
            memberId: UserDefaultStorage.id
        )
        let viewController = ProfileViewController(viewModel: viewModel, isOwn: true)
        return viewController
    }
}
