//
//  EditButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/07/22.
//

import UIKit

import SnapKit
import Then

final class EditButton: UIButton {
    // MARK: - property
    let label = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .medium)
        $0.text = "수정"
    }

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - life cycle
    private func setupLayout() {
        addSubview(label)

        label.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }

    private func configureUI() {
        backgroundColor = .mainBlue
        layer.cornerRadius = 15
        layer.borderColor = UIColor.grey002.cgColor
        layer.borderWidth = 1
    }
}
