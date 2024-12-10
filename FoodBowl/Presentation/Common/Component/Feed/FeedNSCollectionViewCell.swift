//
//  FeedNSCollectionViewCell.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/07/22.
//

import Combine
import UIKit

import SnapKit
import Then

final class FeedNSCollectionViewCell: UICollectionViewCell, BaseViewType {
    
    // MARK: - ui component
    
    private let userInfoButton = UserInfoButton()
    private let commentLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .light)
        $0.textColor = .mainTextColor
        $0.numberOfLines = 0
    }
    private let photoListView = PhotoListView()
    
    // MARK: - property
    
    var cancellable: Set<AnyCancellable> = Set()
    
    private let cellDidTapSubject = PassthroughSubject<Void, Never>()
    var cellDidTapPublisher: AnyPublisher<Void, Never> {
        return cellDidTapSubject.eraseToAnyPublisher()
    }
    var userInfoButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.userInfoButton.buttonTapPublisher
    }
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
        self.setupAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        self.contentView.addSubviews(
            self.userInfoButton,
            self.commentLabel,
            self.photoListView
        )
        
        self.userInfoButton.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        self.commentLabel.snp.makeConstraints {
            $0.top.equalTo(self.userInfoButton.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.bottom.equalTo(self.photoListView.snp.top).offset(-10)
        }
        
        self.photoListView.snp.makeConstraints {
            $0.top.equalTo(self.commentLabel.snp.bottom)
            $0.bottom.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
    -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
        
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        
        layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return layoutAttributes
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cancellable.removeAll()
    }
    
    private func setupAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func cellTapped() {
        self.cellDidTapSubject.send(())
    }
    
    func userInfo() -> UserInfoButton {
        self.userInfoButton
    }
}

// MARK: - Public - func
extension FeedNSCollectionViewCell {
    func configureCell(_ reviewItem: Review) {
        let member = reviewItem.member
        let comment = reviewItem.comment
        
        self.userInfoButton.configureUser(member)
        
        self.commentLabel.text = comment.content
        if comment.imagePaths.isEmpty {
            self.photoListView.isHidden = true
            
            self.photoListView.snp.remakeConstraints {
                $0.top.equalTo(self.commentLabel.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview().inset(14)
                $0.height.equalTo(0)
            }
        } else {
            self.photoListView.photos = comment.imagePaths
            self.photoListView.isHidden = false
            
            self.photoListView.snp.remakeConstraints {
                $0.top.equalTo(self.commentLabel.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview().inset(14)
                $0.height.equalTo(100)
            }
        }
    }
}
