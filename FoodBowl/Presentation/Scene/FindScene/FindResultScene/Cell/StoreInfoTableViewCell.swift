//
//  StoreInfoTableViewCell.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/18.
//

import UIKit

import SnapKit
import Then

final class StoreInfoTableViewCell: UITableViewCell, BaseViewType {
    
    // MARK: - ui component
    
    private let storeNameLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium)
        $0.textColor = .mainTextColor
    }
    private let storeCategoryLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .caption1, weight: .regular)
        $0.textColor = .mainTextColor
    }
    private let storeAddressLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .caption1, weight: .light)
        $0.textColor = .subTextColor
    }
    private let storeReviewCountLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .caption1, weight: .light)
        $0.textColor = .subTextColor
    }
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.baseInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {
        self.contentView.addSubviews(
            self.storeNameLabel,
            self.storeCategoryLabel,
            self.storeAddressLabel,
            self.storeReviewCountLabel
        )

        self.storeNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.top.equalToSuperview().inset(15)
        }
        
        self.storeCategoryLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.top.equalToSuperview().inset(16)
        }

        self.storeAddressLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.top.equalTo(storeNameLabel.snp.bottom).offset(3)
        }

        self.storeReviewCountLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.top.equalTo(storeNameLabel.snp.bottom).offset(3)
        }
    }

    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
}

// MARK: - Public - func
extension StoreInfoTableViewCell {
    func configureCell(_ store: Store) {
        self.storeNameLabel.text = store.name
        self.storeCategoryLabel.text = store.category
        self.storeAddressLabel.text = "\(store.address), \(store.distance)"
        self.storeReviewCountLabel.text = "후기 \(store.reviewCount)"
    }
}
