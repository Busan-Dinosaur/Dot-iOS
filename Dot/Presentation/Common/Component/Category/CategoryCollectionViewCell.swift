//
//  CategoryCollectionViewCell.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/15.
//

import UIKit

import SnapKit
import Then

final class CategoryCollectionViewCell: UICollectionViewCell, BaseViewType {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .mainTextColor
                categoryLabel.textColor = .mainBackgroundColor
            } else {
                backgroundColor = .mainBackgroundColor
                categoryLabel.textColor = .mainTextColor
            }
        }
    }

    // MARK: - property
    
    let categoryLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .light)
        $0.textColor = .mainTextColor
    }
    
    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {
        self.contentView.addSubviews(self.categoryLabel)

        self.categoryLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(14)
            $0.top.bottom.equalToSuperview().inset(6)
        }
    }

    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
        self.layer.cornerRadius = 14
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.grey002.cgColor
    }
}
