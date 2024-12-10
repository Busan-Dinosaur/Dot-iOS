//
//  StoreTableViewCell.swift
//  FoodBowl
//
//  Created by Coby Kim on 2023/01/13.
//

import UIKit

import SnapKit
import Then

final class StoreTableViewCell: UITableViewCell, BaseViewType {
    
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
    private let storeDistanceLabel = UILabel().then {
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
            self.storeDistanceLabel
        )

        self.storeNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.top.equalToSuperview().inset(12)
        }
        
        self.storeCategoryLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.top.equalToSuperview().inset(14)
        }

        self.storeAddressLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.bottom.equalToSuperview().inset(12)
        }

        self.storeDistanceLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.bottom.equalToSuperview().inset(12)
        }
    }

    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
}

// MARK: - Public - func
extension StoreTableViewCell {
    func configureCell(_ store: Store) {
        self.storeNameLabel.text = store.name
        self.storeCategoryLabel.text = store.category
        self.storeAddressLabel.text = store.address
        self.storeDistanceLabel.text = store.distance
        
        if store.originalCategory != "음식점" {
            self.storeCategoryLabel.text = store.originalCategory
        }
    }
}
