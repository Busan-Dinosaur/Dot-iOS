//
//  StoreDetailView.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/20/23.
//

import Combine
import UIKit

import SnapKit
import Then

final class StoreDetailView: UIView, BaseViewType {
    
    private enum ConstantSize {
        static let sectionContentInset: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: SizeLiteral.verticalPadding,
            trailing: 0
        )
        static let groupInterItemSpacing: CGFloat = 20
    }
    
    // MARK: - ui component
    
    let storeHeaderView = StoreHeaderView()
    private lazy var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout()).then {
        $0.showsVerticalScrollIndicator = false
        $0.register(FeedNSCollectionViewCell.self, forCellWithReuseIdentifier: FeedNSCollectionViewCell.className)
        $0.backgroundColor = .mainBackgroundColor
    }
    private var refresh = UIRefreshControl()
    
    // MARK: - property
    
    let reviewToggleButtonDidTapPublisher = PassthroughSubject<Bool, Never>()
    let bookmarkButtonDidTapPublisher = PassthroughSubject<Bool, Never>()
    let refreshPublisher = PassthroughSubject<Void, Never>()
    
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
    
    // MARK: - func
    
    func collectionView() -> UICollectionView {
        return self.listCollectionView
    }
    
    func refreshControl() -> UIRefreshControl {
        return self.refresh
    }
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(
            self.storeHeaderView,
            self.listCollectionView
        )

        self.storeHeaderView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }

        self.listCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.storeHeaderView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
    
    // MARK: - Private - func

    private func setupAction() {
        let bookmarkAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.bookmarkButtonDidTapPublisher.send(self.storeHeaderView.bookmarkButton.isSelected)
        }
        self.storeHeaderView.bookmarkButton.addAction(bookmarkAction, for: .touchUpInside)
        
        let refreshAction = UIAction { [weak self] _ in
            self?.refreshPublisher.send()
        }
        self.refresh.addAction(refreshAction, for: .valueChanged)
        self.refresh.tintColor = .grey002
        self.listCollectionView.refreshControl = self.refresh
    }
}

// MARK: - UICollectionViewLayout
extension StoreDetailView {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { index, environment -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(200)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = ConstantSize.sectionContentInset
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(200)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = ConstantSize.groupInterItemSpacing
            
            return section
        }

        return layout
    }
}
