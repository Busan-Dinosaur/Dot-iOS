//
//  UIViewController+Combine.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/20/23.
//

import Combine
import UIKit

extension UIViewController {
    var viewDidLoadPublisher: AnyPublisher<Void, Never> {
        let selector = #selector(UIViewController.viewDidLoad)
        return Just(selector)
            .map { _ in Void() }
            .eraseToAnyPublisher()
    }
}
