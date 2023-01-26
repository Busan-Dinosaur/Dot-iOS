//
//  PlusButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/10.
//

import UIKit

final class PlusButton: UIButton {
    // MARK: - init

    override init(frame _: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 30, height: 30)))
        configUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - life cycle

    private func configUI() {
        setImage(ImageLiteral.btnPlus.resize(to: CGSize(width: 24, height: 24)), for: .normal)
        tintColor = .black
    }
}
