//
//  FollowButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/09.
//

import UIKit

import SnapKit
import Then

final class FollowButton: UIButton, BaseViewType {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .grey001
                label.text = "팔로잉"
            } else {
                backgroundColor = .mainPink
                label.text = "팔로우"
            }
        }
    }

    // MARK: - ui component
    
    let label = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .medium)
    }

    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - life cycle
    
    func setupLayout() {
        self.addSubview(self.label)

        self.label.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }

    func configureUI() {
        self.backgroundColor = .mainPink
        self.layer.cornerRadius = 15
        self.layer.borderColor = UIColor.grey002.cgColor
        self.layer.borderWidth = 1
    }
}
