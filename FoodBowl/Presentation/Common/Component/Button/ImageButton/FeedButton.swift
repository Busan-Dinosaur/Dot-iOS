//
//  FeedButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/28.
//

import UIKit

final class FeedButton: UIButton {
    
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
        self.setImage(ImageLiteral.btnFeed.resize(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), for: .normal)
        self.tintColor = .mainTextColor
    }
}
