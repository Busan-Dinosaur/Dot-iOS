//
//  FeedListView.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/07/22.
//

import Combine
import UIKit

import SnapKit
import Then

final class FeedListView: UIView, BaseViewType {
    
    private enum ConstantSize {
        static let sectionContentInset: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(
            top: SizeLiteral.verticalPadding,
            leading: 0,
            bottom: SizeLiteral.verticalPadding,
            trailing: 0
        )
        static let groupInterItemSpacing: CGFloat = 20
    }
    
    // MARK: - ui component
    
    private let storeCountLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .regular)
        $0.textColor = .subTextColor
        $0.text = "0개의 맛집"
    }
    
    private let borderView = UIView().then {
        $0.backgroundColor = .grey002.withAlphaComponent(0.5)
    }

    private lazy var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout()).then {
        $0.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: FeedCollectionViewCell.className)
        $0.backgroundColor = .mainBackgroundColor
    }
    
    private var refresh = UIRefreshControl()
    
    // MARK: - property
    
    let refreshPublisher = PassthroughSubject<Void, Never>()

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

    // MARK: - func
    
    func collectionView() -> UICollectionView {
        return self.listCollectionView
    }
    
    func refreshControl() -> UIRefreshControl {
        return self.refresh
    }
    
    func updateStoreCount(to count: Int) {
        self.storeCountLabel.text = "\(count)개의 맛집"
    }
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(
            self.storeCountLabel,
            self.borderView,
            self.listCollectionView
        )

        self.storeCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
        }
        
        self.borderView.snp.makeConstraints {
            $0.top.equalTo(self.storeCountLabel.snp.bottom).offset(SizeLiteral.verticalPadding)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        self.listCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.borderView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
    
    // MARK: - Private - func

    private func setupAction() {
        let refreshAction = UIAction { [weak self] _ in
            self?.refreshPublisher.send()
        }
        self.refresh.addAction(refreshAction, for: .valueChanged)
        self.refresh.tintColor = .grey002
        self.listCollectionView.refreshControl = self.refresh
    }
}

// MARK: - UICollectionViewLayout
extension FeedListView {
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
