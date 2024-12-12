//
//  YPImagePicker+Extension.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/23.
//

import UIKit

import SnapKit
import Then
import YPImagePicker

extension YPSelectionsGalleryVC {
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let controllersCount = navigationController?.viewControllers.count, controllersCount > 1 {
            lazy var backButton = BackButton().then {
                let buttonAction = UIAction { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
                $0.addAction(buttonAction, for: .touchUpInside)
            }

            let leftOffsetBackButton = removeBarButtonItemOffset(with: backButton, offsetX: 10)
            let backButtonView = makeBarButtonItem(with: leftOffsetBackButton)

            navigationItem.leftBarButtonItem = backButtonView
            title = "필터 선택"
        }
    }
}

extension YPPhotoFiltersVC {
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let controllersCount = navigationController?.viewControllers.count, controllersCount > 1 {
            lazy var backButton = BackButton().then {
                let buttonAction = UIAction { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
                $0.addAction(buttonAction, for: .touchUpInside)
            }

            let leftOffsetBackButton = removeBarButtonItemOffset(with: backButton, offsetX: 10)
            let backButtonView = makeBarButtonItem(with: leftOffsetBackButton)

            navigationItem.leftBarButtonItem = backButtonView
            title = "필터 선택"
        }
    }
}
