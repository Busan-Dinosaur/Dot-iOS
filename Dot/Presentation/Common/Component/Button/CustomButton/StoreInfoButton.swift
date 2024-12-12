//
//  StoreInfoButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/26.
//

import UIKit

import SnapKit
import Then

final class StoreInfoButton: UIButton, BaseViewType {
    
    // MARK: - ui component
    
    let storeNameLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .medium)
        $0.textColor = .mainTextColor
    }
    let storeCategoryLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .caption2, weight: .light)
        $0.textColor = .mainTextColor
    }
    let storeAddressLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .caption2, weight: .light)
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
        
        self.storeNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(14)
            $0.top.equalToSuperview().inset(12)
            $0.width.lessThanOrEqualTo(SizeLiteral.fullWidth - 160)
        }
        
        self.storeCategoryLabel.snp.makeConstraints {
            $0.leading.equalTo(self.storeNameLabel.snp.trailing).offset(6)
            $0.centerY.equalTo(self.storeNameLabel)
        }
        
        self.storeAddressLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(14)
            $0.top.equalTo(self.storeNameLabel.snp.bottom).offset(2)
            $0.width.lessThanOrEqualTo(SizeLiteral.fullWidth - 120)
        }
        
        self.bookmarkButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }
    }
    
    func configureUI() {
        self.makeBorderLayer(color: .grey002)
    }
}

// MARK: - Public - func
extension StoreInfoButton {
    func configureStore(_ store: Store) {
        self.storeNameLabel.text = store.name
        self.storeCategoryLabel.text = store.category
        self.storeAddressLabel.text = "\(store.address), \(store.distance)"
        self.bookmarkButton.isSelected = store.isBookmarked
    }
}
