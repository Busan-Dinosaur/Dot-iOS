//
//  FindView.swift
//  FoodBowl
//
//  Created by Coby on 1/19/24.
//

import Combine
import UIKit

import SnapKit
import Then

final class FindView: UIView, BaseViewType {
    
    private enum ConstantSize {
        static let itemContentInset: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(
            top: 4,
            leading: 4,
            bottom: 4,
            trailing: 4
        )
        static let sectionContentInset: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: SizeLiteral.horizantalPadding - 4,
            bottom: 10,
            trailing: SizeLiteral.horizantalPadding - 4
        )
    }
    
    // MARK: - ui component
    
    private let plusButton = PlusButton()
    private let findGuideLabel = PaddingLabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .bold)
        $0.text = "둘러보기"
        $0.textColor = .mainTextColor
        $0.padding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        $0.frame = CGRect(x: 0, y: 0, width: 150, height: 0)
    }
    let findResultViewController = FindResultViewController()
    lazy var searchController = UISearchController(searchResultsController: self.findResultViewController).then {
        $0.searchBar.placeholder = "검색"
        $0.searchBar.setValue("취소", forKey: "cancelButtonText")
        $0.searchBar.tintColor = .mainColor
        $0.searchBar.scopeButtonTitles = ["맛집", "유저"]
        $0.obscuresBackgroundDuringPresentation = true
        $0.searchBar.showsScopeBar = false
        $0.searchBar.sizeToFit()
    }
    private lazy var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout()).then {
        $0.showsVerticalScrollIndicator = false
        $0.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.className)
        $0.backgroundColor = .mainBackgroundColor
    }
    private var refresh = UIRefreshControl()
    
    // MARK: - property
    
    var plusButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.plusButton.buttonTapPublisher
    }
    let searchStoresPublisher = PassthroughSubject<String, Never>()
    let searchMembersPublisher = PassthroughSubject<String, Never>()
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
    
    func configureNavigationBarItem(_ navigationController: UINavigationController) {
        let navigationItem = navigationController.topViewController?.navigationItem
        let findGuideLabel = navigationController.makeBarButtonItem(with: findGuideLabel)
        let plusButton = navigationController.makeBarButtonItem(with: plusButton)
        navigationItem?.leftBarButtonItem = findGuideLabel
        navigationItem?.rightBarButtonItem = plusButton
        navigationItem?.searchController = self.searchController
    }
    
    func collectionView() -> UICollectionView {
        return self.listCollectionView
    }
    
    func refreshControl() -> UIRefreshControl {
        return self.refresh
    }
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(self.listCollectionView)

        self.listCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
extension FindView {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { index, environment -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalWidth(1/3)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = ConstantSize.itemContentInset
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1/3)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 3
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = ConstantSize.sectionContentInset
            
            return section
        }

        return layout
    }
}
