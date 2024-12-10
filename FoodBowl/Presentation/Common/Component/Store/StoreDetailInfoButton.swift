//
//  StoreDetailInfoButton.swift
//  FoodBowl
//
//  Created by Coby on 1/24/24.
//

import Combine
import UIKit

import SnapKit
import Then

final class StoreDetailInfoButton: UIButton, BaseViewType {
    
    // MARK: - ui component
    
    private let mapButton = MapButton()
    private let storeNameLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium)
        $0.textColor = .mainTextColor
    }
    private let storeCategoryLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .light)
        $0.textColor = .mainTextColor
    }
    private let storeAddressLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .light)
        $0.textColor = .subTextColor
    }
    private let bookmarkButton = BookmarkButton()
    
    // MARK: - property
    
    private var cancellable: Set<AnyCancellable> = Set()
    
    let mapButtonDidTapPublisher = PassthroughSubject<String, Never>()
    let bookmarkButtonDidTapPublisher = PassthroughSubject<Bool, Never>()

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
            self.mapButton,
            self.storeNameLabel,
            self.storeCategoryLabel,
            self.storeAddressLabel,
            self.bookmarkButton
        )
        
        self.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.size.width)
        }

        self.mapButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
        }

        self.storeNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalTo(mapButton.snp.trailing).offset(12)
            $0.width.lessThanOrEqualTo(SizeLiteral.fullWidth - 140)
        }

        self.storeCategoryLabel.snp.makeConstraints {
            $0.leading.equalTo(self.storeNameLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(self.storeNameLabel)
        }

        self.storeAddressLabel.snp.makeConstraints {
            $0.top.equalTo(self.storeNameLabel.snp.bottom).offset(2)
            $0.leading.equalTo(self.mapButton.snp.trailing).offset(12)
            $0.width.lessThanOrEqualTo(SizeLiteral.fullWidth - 100)
        }

        self.bookmarkButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
        }
        
        self.snp.makeConstraints {
            $0.height.equalTo(60)
        }
    }
    
    func configureUI() {
        self.backgroundColor = .subBackgroundColor
    }
    
    func bookmarkToggle() {
        self.bookmarkButton.isSelected.toggle()
        self.updateBookmarkButton(isBookmarked: self.bookmarkButton.isSelected)
    }
}

// MARK: - Public - func
extension StoreDetailInfoButton {
    func configureStore(_ store: Store) {
        self.storeNameLabel.text = store.name
        self.storeCategoryLabel.text = store.category
        self.storeAddressLabel.text = "\(store.address), \(store.distance)"
        self.mapButton.tapPublisher
            .sink { [weak self] in
                self?.mapButtonDidTapPublisher.send(store.url)
            }
            .store(in: &self.cancellable)
        
        self.updateBookmarkButton(isBookmarked: store.isBookmarked)
    }
    
    func updateBookmarkButton(isBookmarked: Bool) {
        self.cancellable.removeAll()
        
        self.bookmarkButton.isSelected = isBookmarked
        self.bookmarkButton.tapPublisher
            .sink { [weak self] in
                self?.bookmarkButtonDidTapPublisher.send(isBookmarked)
            }
            .store(in: &self.cancellable)
    }
}
