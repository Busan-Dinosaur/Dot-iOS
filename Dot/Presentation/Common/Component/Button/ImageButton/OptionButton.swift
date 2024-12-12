//
//  OptionButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/10.
//

import UIKit

final class OptionButton: UIButton {
    
    // MARK: - init
    
    override init(frame _: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 30, height: 30)))
        self.configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        self.setImage(ImageLiteral.btnOption.resize(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate), for: .normal)
        self.tintColor = .mainTextColor
    }
}
