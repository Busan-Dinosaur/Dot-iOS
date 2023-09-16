//
//  UserInfoView.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/24.
//

import UIKit

import SnapKit
import Then

final class UserInfoView: UIButton {
    // MARK: - property
    let userImageView = UIImageView().then {
        $0.image = ImageLiteral.defaultProfile
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.grey002.cgColor
        $0.layer.borderWidth = 1
    }

    let userNameLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium)
        $0.textColor = .mainText
        $0.text = "홍길동"
    }

    let userFollowerLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .light)
        $0.textColor = .subText
        $0.text = "팔로워 100명"
    }

    let followButton = FollowButton()

    let optionButton = OptionButton()

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubviews(userImageView, userNameLabel, userFollowerLabel, optionButton)

        userImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(BaseSize.horizantalPadding)
            $0.top.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(40)
        }

        userNameLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).offset(12)
            $0.top.equalToSuperview().inset(14)
            $0.height.equalTo(18)
        }

        userFollowerLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).offset(12)
            $0.top.equalTo(userNameLabel.snp.bottom).offset(4)
        }

        optionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(BaseSize.horizantalPadding)
            $0.centerY.equalToSuperview()
        }
    }
}