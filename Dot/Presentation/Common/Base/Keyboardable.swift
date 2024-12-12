//
//  Keyboardable.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/20/23.
//

import UIKit

protocol Keyboardable {
    func setupKeyboardGesture()
}

extension Keyboardable where Self: UIViewController {
    func setupKeyboardGesture() {
        self.hidekeyboardWhenTappedAround()
    }
}
