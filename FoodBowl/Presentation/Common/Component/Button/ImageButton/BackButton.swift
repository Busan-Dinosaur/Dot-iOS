//
//  BackButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import UIKit

final class BackButton: UIButton {
    
    // MARK: - init
    
    override init(frame _: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
        self.configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        self.setImage(ImageLiteral.btnBack.resize(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate), for: .normal)
        self.tintColor = .mainTextColor
    }
}
