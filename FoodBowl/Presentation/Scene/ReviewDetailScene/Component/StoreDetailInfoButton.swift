//
//  StoreDetailInfoButton.swift
//  FoodBowl
//
//  Created by Coby on 1/24/24.
//

import UIKit

import SnapKit
import Then

final class StoreDetailInfoButton: UIButton, BaseViewType {
    
    // MARK: - ui component
    
    private let storeNameLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium)
        $0.textColor = .mainTextColor
    }
    private let storeCategoryLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .light)
        $0.textColor = .mainTextColor
    }
    private let storeAddressLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .light)
        $0.textColor = .subTextColor
    }
    let bookmarkButton = BookmarkButton()

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
            self.storeNameLabel,
            self.storeCategoryLabel,
            self.storeAddressLabel,
            self.bookmarkButton
        )
        
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.size.width)
        }

        self.storeNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.width.lessThanOrEqualTo(SizeLiteral.fullWidth - 90)
        }

        self.storeCategoryLabel.snp.makeConstraints {
            $0.leading.equalTo(self.storeNameLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(self.storeNameLabel)
        }

        self.storeAddressLabel.snp.makeConstraints {
            $0.top.equalTo(self.storeNameLabel.snp.bottom).offset(2)
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.width.lessThanOrEqualTo(SizeLiteral.fullWidth - 50)
        }

        self.bookmarkButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(50)
        }
    }
    
    func configureUI() {
        self.backgroundColor = .subBackgroundColor
    }
}

// MARK: - Public - func
extension StoreDetailInfoButton {
    func configureStore(_ store: Store) {
        self.storeNameLabel.text = store.name
        self.storeCategoryLabel.text = store.category
        self.storeAddressLabel.text = "\(store.address), \(store.distance)"
        self.bookmarkButton.isSelected = store.isBookmarked
    }
}
