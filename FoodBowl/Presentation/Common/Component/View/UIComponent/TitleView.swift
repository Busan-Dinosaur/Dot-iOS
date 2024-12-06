//
//  TitleView.swift
//  FoodBowl
//
//  Created by Coby on 12/6/24.
//

import UIKit

import SnapKit
import Then

final class TitleView: UIView, BaseViewType {
    
    // MARK: - ui component

    private let titleLabel = PaddingLabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .bold)
        $0.textColor = .mainTextColor
        $0.text = "푸드볼"
    }

    // MARK: - init
    
    init(title: String) {
        super.init(frame: .zero)
        self.baseInit()
        self.titleLabel.text = title
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {
        self.addSubviews(
            self.titleLabel
        )
        
        self.titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(SizeLiteral.verticalPadding)
            $0.centerY.equalToSuperview()
        }
        
        self.snp.makeConstraints {
            $0.height.equalTo(50)
        }
    }

    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
}
