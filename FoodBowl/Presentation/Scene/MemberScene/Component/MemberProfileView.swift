//
//  MemberProfileView.swift
//  FoodBowl
//
//  Created by Coby on 12/8/24.
//

import Combine
import UIKit

import Kingfisher
import SnapKit
import Then

final class MemberProfileView: UIView, BaseViewType {
    
    // MARK: - ui component
    
    private let userImageView = UIImageView().then {
        $0.image = ImageLiteral.profile
        $0.layer.cornerRadius = 25
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.grey002.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let followerInfoButton = FollowInfoButton().then {
        $0.infoLabel.text = "팔로워"
    }
    
    private let followingInfoButton = FollowInfoButton().then {
        $0.infoLabel.text = "팔로잉"
    }
    
    private let userInfoLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .regular)
        $0.textColor = .mainTextColor
        $0.numberOfLines = 1
    }
    
    private let followButton = FollowButton()
    
    // MARK: - property
    
    var followerButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.followerInfoButton.buttonTapPublisher
    }
    var followingButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.followingInfoButton.buttonTapPublisher
    }
    let followButtonDidTapPublisher = PassthroughSubject<Bool, Never>()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
        self.setupAction()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(
            self.userImageView,
            self.followerInfoButton,
            self.followingInfoButton,
            self.userInfoLabel,
            self.followButton
        )
        
        self.userImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.top.equalToSuperview()
            $0.width.height.equalTo(50)
        }
        
        self.followerInfoButton.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).offset(14)
            $0.top.equalToSuperview().inset(4)
            $0.height.equalTo(20)
        }
        
        self.followingInfoButton.snp.makeConstraints {
            $0.leading.equalTo(self.followerInfoButton.snp.trailing).offset(12)
            $0.top.equalToSuperview().inset(4)
            $0.height.equalTo(20)
        }
        
        self.userInfoLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).offset(14)
            $0.top.equalTo(self.followerInfoButton.snp.bottom).offset(6)
            $0.width.equalTo(SizeLiteral.fullWidth - 140)
        }
        
        self.followButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.width.equalTo(60)
            $0.height.equalTo(30)
        }
        
        self.snp.makeConstraints {
            $0.height.equalTo(60)
        }
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
    
    func setupAction() {
        let followAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.followButtonDidTapPublisher.send(self.followButton.isSelected)
        }
        self.followButton.addAction(followAction, for: .touchUpInside)
    }
}

extension MemberProfileView {
    func configureMember(member: Member) {
        if let url = member.profileImageUrl {
            self.userImageView.kf.setImage(with: URL(string: url))
        } else {
            self.userImageView.image = ImageLiteral.profile
        }
        self.userInfoLabel.text = member.introduction == "" ? "소개를 작성하지 않았어요." : member.introduction
        self.followerInfoButton.numberLabel.text = "\(member.followerCount)명"
        self.followingInfoButton.numberLabel.text = "\(member.followingCount)명"
        self.followButton.isSelected = member.isFollowing
        self.followButton.isHidden = member.isMyProfile
    }
    
    func followToggle() {
        self.followButton.isSelected.toggle()
    }
}
