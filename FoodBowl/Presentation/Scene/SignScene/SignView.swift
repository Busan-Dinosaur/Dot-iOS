//
//  SignView.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/20/23.
//

import AuthenticationServices
import Combine
import UIKit

import SnapKit
import Then

final class SignView: UIView, BaseViewType {
    
    // MARK: - ui component
    
    private let logoImageView = UIImageView().then {
        $0.image = ImageLiteral.logo
    }
    private lazy var appleSignButton = ASAuthorizationAppleIDButton(
        type: .signIn,
        style: .white
    ).then {
        $0.cornerRadius = 8
    }
    
    // MARK: - property
    
    var appleSignButtonTapPublisher: AnyPublisher<Void, Never> {
        return self.appleSignButton.buttonTapPublisher
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
            self.logoImageView,
            self.appleSignButton
        )

        self.logoImageView.snp.makeConstraints {
            $0.width.height.equalTo(300)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.snp.top).inset(150)
        }

        self.appleSignButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.bottom.equalToSuperview().inset(SizeLiteral.bottomPadding)
            $0.height.equalTo(60)
        }
    }
    
    func configureUI() {
        self.backgroundColor = .mainColor
    }
}
