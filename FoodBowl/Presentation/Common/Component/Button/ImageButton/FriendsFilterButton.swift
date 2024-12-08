//
//  FriendsFilterButton.swift
//  FoodBowl
//
//  Created by Coby on 12/8/24.
//

import UIKit

final class FriendsFilterButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                setImage(
                    ImageLiteral.friendsFill.resize(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
                tintColor = .mainBackgroundColor
                backgroundColor = .mainColor
            } else {
                setImage(
                    ImageLiteral.friends.resize(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
                tintColor = .mainColor
                backgroundColor = .mainBackgroundColor
            }
        }
    }

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
        self.isSelected = false
    }
}
