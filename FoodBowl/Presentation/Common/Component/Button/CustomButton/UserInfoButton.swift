//
//  UserInfoButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/11/14.
//

import Combine
import UIKit

import Kingfisher
import SnapKit
import Then

final class UserInfoButton: UIButton, BaseViewType {
    
    // MARK: - ui component
    
    private let userImageView = UIImageView().then {
        $0.image = ImageLiteral.profile
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.grey002.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let userNameLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium)
        $0.textColor = .mainTextColor
    }
    
    private let userFollowerLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .light)
        $0.textColor = .subTextColor
    }
    
    private let optionButton = OptionButton()
    
    // MARK: - property
    
    var optionButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.optionButton.buttonTapPublisher
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
            self.userImageView,
            self.userNameLabel, 
            self.userFollowerLabel,
            self.optionButton
        )
        
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.size.width)
        }
        
        self.userImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }
        
        self.userNameLabel.snp.makeConstraints {
            $0.leading.equalTo(self.userImageView.snp.trailing).offset(12)
            $0.top.equalToSuperview().inset(14)
            $0.height.equalTo(18)
        }
        
        self.userFollowerLabel.snp.makeConstraints {
            $0.leading.equalTo(self.userImageView.snp.trailing).offset(12)
            $0.top.equalTo(self.userNameLabel.snp.bottom).offset(2)
        }
        
        self.optionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(50)
        }
        
        self.snp.makeConstraints {
            $0.height.equalTo(64)
        }
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
    
    func option() -> OptionButton {
        self.optionButton
    }
}

extension UserInfoButton {
    func configureUser(_ member: Member) {
        if let url = member.profileImageUrl {
            let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: 40, height: 40), mode: .aspectFill)
            
            self.userImageView.kf.setImage(
                with: URL(string: url),
                options: [
                    .processor(resizingProcessor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            self.userImageView.image = ImageLiteral.profile
        }
        
        self.userNameLabel.text = member.nickname
        self.userFollowerLabel.text = "팔로워 \(member.followerCount)명"
    }
}
