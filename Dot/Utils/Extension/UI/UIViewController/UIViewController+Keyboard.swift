//
//  UIViewController+Keyboard.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/20/23.
//

import UIKit

extension UIViewController {
    func hidekeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func endEditingView() {
        view.endEditing(true)
    }
}
