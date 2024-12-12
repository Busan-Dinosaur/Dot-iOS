//
//  SelectedStoreView.swift
//  FoodBowl
//
//  Created by Coby Kim on 2023/01/13.
//

import Combine
import UIKit

import SnapKit
import Then

final class SelectedStoreView: UIView, BaseViewType {
    
    // MARK: - ui component

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
    
    private let mapButton = MapButton()
    
    // MARK: - property
    
    private var cancellable: Set<AnyCancellable> = Set()
    
    let mapButtonDidTapPublisher = PassthroughSubject<String, Never>()

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - base func

    func setupLayout() {
        self.addSubviews(
            self.storeNameLabel,
            self.storeCategoryLabel,
            self.storeAddressLabel,
            self.mapButton
        )

        self.storeNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(14)
            $0.top.equalToSuperview().inset(12)
            $0.width.lessThanOrEqualTo(SizeLiteral.fullWidth - 140)
        }
        
        self.storeCategoryLabel.snp.makeConstraints {
            $0.leading.equalTo(self.storeNameLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(self.storeNameLabel)
        }

        self.storeAddressLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.lessThanOrEqualTo(SizeLiteral.fullWidth - 100)
        }

        self.mapButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }
    }

    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
        self.makeBorderLayer(color: .grey002)
    }
}

extension SelectedStoreView {
    func configureStore(_ store: Store) {
        self.cancellable.removeAll()
        self.mapButton.tapPublisher
            .sink { [weak self] in
                self?.mapButtonDidTapPublisher.send(store.url)
            }
            .store(in: &self.cancellable)
        
        self.storeNameLabel.text = store.name
        self.storeCategoryLabel.text = store.category
        self.storeAddressLabel.text = "\(store.address), \(store.distance)"
    }
}
