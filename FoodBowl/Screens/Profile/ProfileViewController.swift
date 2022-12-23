//
//  ProfileViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import UIKit

import SnapKit
import Then

final class ProfileViewController: BaseViewController {
    // MARK: - property

    private let screenText = UILabel().then {
        $0.textColor = .red
        $0.text = "Profile"
    }

    // MARK: - life cycle

    override func render() {
        view.addSubview(screenText)
        screenText.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
