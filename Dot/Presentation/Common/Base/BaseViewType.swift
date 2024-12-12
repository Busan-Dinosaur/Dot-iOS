//
//  BaseViewType.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/20/23.
//

import UIKit

protocol BaseViewType: UIView {
    func setupLayout()
    func configureUI()
}

extension BaseViewType {
    func baseInit() {
        self.setupLayout()
        self.configureUI()
    }
}
