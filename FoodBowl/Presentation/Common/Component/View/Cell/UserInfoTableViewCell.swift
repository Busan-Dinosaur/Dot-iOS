//
//  UserInfoTableViewCell.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/18.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class UserInfoTableViewCell: UITableViewCell, BaseViewType {

    // MARK: - ui component
    
    private let userImageView = UIImageView().then {
        $0.image = ImageLiteral.defaultProfile
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
    private let followButton = FollowButton()
    
    // MARK: - property
    
    var followButtonTapAction: ((UserInfoTableViewCell) -> Void)?
    
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
        self.contentView.addSubviews(self.userImageView, self.userNameLabel, self.userFollowerLabel, self.followButton)

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
            $0.top.equalTo(self.userNameLabel.snp.bottom).offset(4)
        }

        self.followButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalTo(30)
        }
    }

    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
    
    private func setupAction() {
        self.followButton.addAction(UIAction { _ in self.followButtonTapAction?(self) }, for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.userImageView.image = nil
    }
}

// MARK: - Public - func
extension UserInfoTableViewCell {
    func configureCell(_ member: Member) {
        self.userNameLabel.text = member.nickname
        self.userFollowerLabel.text = "팔로워 \(member.followerCount)명"
        if let url = member.profileImageUrl {
            self.userImageView.kf.setImage(with: URL(string: url))
        } else {
            self.userImageView.image = ImageLiteral.defaultProfile
        }
        
        if member.isMyProfile {
            self.followButton.isHidden = true
        } else {
            self.followButton.isHidden = false
            self.followButton.isSelected = member.isFollowing
        }
    }
}
