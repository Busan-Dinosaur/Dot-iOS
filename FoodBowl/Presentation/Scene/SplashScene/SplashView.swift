//
//  SplashView.swift
//  FoodBowl
//
//  Created by Coby on 2/1/24.
//

import Combine
import UIKit

import SnapKit
import Then

final class SplashView: UIView, BaseViewType {
    
    // MARK: - ui component
    
    private let logoImageView = UIImageView().then {
        $0.image = ImageLiteral.logo
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
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(
            self.logoImageView
        )

        self.logoImageView.snp.makeConstraints {
            $0.width.height.equalTo(300)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.snp.top).inset(150)
        }
    }
    
    func configureUI() {
        self.backgroundColor = .mainPink
    }
}
