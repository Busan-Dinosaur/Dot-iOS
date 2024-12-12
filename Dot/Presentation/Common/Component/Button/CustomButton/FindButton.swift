//
//  FindButton.swift
//  FoodBowl
//
//  Created by Coby on 2/18/24.
//

import UIKit

import SnapKit
import Then

final class FindButton: UIButton {
    
    // MARK: - property
    private let label = UILabel().then {
        $0.textColor = .mainColor
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .regular)
        $0.text = "추천 친구 찾아보기"
    }
    private let nextView = UIImageView().then {
        $0.image = ImageLiteral.btnForward.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .mainColor
    }

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - life cycle
    private func setupLayout() {
        self.addSubviews(
            self.label,
            self.nextView
        )

        self.label.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
        }
        
        self.nextView.snp.makeConstraints {
            $0.leading.equalTo(self.label.snp.trailing).offset(2)
            $0.centerY.trailing.equalToSuperview()
            $0.width.height.equalTo(10)
        }
    }
}
