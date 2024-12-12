//
//  SearchBarButton.swift
//  FoodBowl
//
//  Created by Coby Kim on 2023/01/13.
//

import UIKit

import SnapKit
import Then

final class SearchBarButton: UIButton, BaseViewType {
    
    // MARK: - ui component
    
    private let searchIconView = UIImageView().then {
        $0.image = ImageLiteral.search.resize(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate)
        $0.tintColor = .subTextColor
    }
    let placeholderLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .callout, weight: .regular)
        $0.textColor = .grey001
        $0.text = "가게 검색"
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

    func setupLayout() {
        self.addSubviews(
            self.searchIconView,
            self.placeholderLabel
        )

        self.searchIconView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(14)
            $0.width.height.equalTo(20)
        }

        self.placeholderLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(self.searchIconView.snp.trailing).offset(10)
            $0.trailing.lessThanOrEqualToSuperview().inset(14)
        }
        
        self.snp.makeConstraints {
            $0.height.equalTo(40)
        }
    }

    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.grey002.cgColor
    }
    
    func setPlaceholder(title: String) {
        self.placeholderLabel.text = title
    }
}
