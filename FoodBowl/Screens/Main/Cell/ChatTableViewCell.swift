//
//  ChatTableViewCell.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/18.
//

import UIKit

import SnapKit
import Then

final class ChatTableViewCell: BaseTableViewCell {
    // MARK: - property

    lazy var userImageButton = UIButton().then {
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }

    let userNameButton = UIButton().then {
        $0.setTitle("홍길동", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .preferredFont(forTextStyle: .subheadline, weight: .medium)
    }

    let dateLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .caption1, weight: .regular)
        $0.textColor = .subText
        $0.text = "10일 전"
    }

    let userCommentLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .light)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.text = "난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데난 별로던데"
    }

    let optionButton = UIImageView().then {
        $0.image = ImageLiteral.btnMore.resize(to: CGSize(width: 12, height: 12))
        $0.tintColor = .subText
    }

    // MARK: - func

    override func render() {
        contentView.addSubviews(userImageButton, userNameButton, dateLabel, optionButton, userCommentLabel)

        userImageButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(10)
            $0.width.height.equalTo(40)
        }

        userNameButton.snp.makeConstraints {
            $0.leading.equalTo(userImageButton.snp.trailing).offset(16)
            $0.top.equalToSuperview().inset(12)
        }

        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(userNameButton.snp.trailing).offset(8)
            $0.centerY.equalTo(userNameButton)
        }

        optionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(14)
        }

        userCommentLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageButton.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(userNameButton.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
}
