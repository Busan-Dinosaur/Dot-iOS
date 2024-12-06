//
//  CategoryListView.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/07/21.
//

import Combine
import UIKit

import SnapKit
import Then

final class CategoryListView: UIView, BaseViewType {
    
    private enum Size {
        static let collectionInset = UIEdgeInsets(
            top: 0,
            left: SizeLiteral.horizantalPadding,
            bottom: 10,
            right: SizeLiteral.horizantalPadding
        )
    }

    private let categories = CategoryType.allCases

    // MARK: - ui component
    
    private let collectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.sectionInset = Size.collectionInset
        $0.minimumLineSpacing = 6
        $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    private lazy var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout).then {
        $0.backgroundColor = .clear
        $0.dataSource = self
        $0.delegate = self
        $0.showsHorizontalScrollIndicator = false
        $0.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.className)
    }
    
    // MARK: - property
    
    let setCategoryPublisher = PassthroughSubject<CategoryType?, Never>()

    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - life cycle
    
    func setupLayout() {
        self.addSubviews(self.listCollectionView)

        self.listCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.snp.makeConstraints {
            $0.height.equalTo(40)
        }
    }

    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension CategoryListView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCollectionViewCell.className,
            for: indexPath
        ) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.categoryLabel.text = self.categories[indexPath.item].rawValue

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell else {
            return true
        }
        
        if cell.isSelected {
            collectionView.deselectItem(at: indexPath, animated: true)
            self.setCategoryPublisher.send(nil)
            return false
        } else {
            self.setCategoryPublisher.send(self.categories[indexPath.item])
            return true
        }
    }
}
