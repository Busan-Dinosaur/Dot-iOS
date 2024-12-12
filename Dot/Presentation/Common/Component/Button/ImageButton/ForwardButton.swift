//
//  ForwardButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/27.
//

import UIKit

final class ForwardButton: UIButton {
    
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
        self.setImage(ImageLiteral.btnForward.resize(to: CGSize(width: 16, height: 16)).withRenderingMode(.alwaysTemplate), for: .normal)
        self.tintColor = .grey001
    }
}
