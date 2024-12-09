//
//  RecommendViewController.swift
//  FoodBowl
//
//  Created by Coby on 2/18/24.
//

import Combine
import UIKit

import SnapKit
import Then

final class RecommendViewController: UIViewController, Navigationable, Helperable {
    
    enum Section: CaseIterable {
        case main
    }
    
    // MARK: - ui component
    
    private let followView: FollowView = FollowView()
    private let emptyMemberView = EmptyListView().then {
        $0.configureEmptyView(message: "추천 유저가 없어요.")
    }
    
    // MARK: - property
    
    private let viewModel: any BaseViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Member>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Member>!
    
    private let followButtonDidTapPublisher = PassthroughSubject<(Int, Bool), Never>()
    
    // MARK: - init
    
    init(viewModel: RecommendViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(#file) is dead")
    }
    
    // MARK: - life cycle
    
    override func loadView() {
        self.view = self.followView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDataSource()
        self.bindViewModel()
        self.setupNavigation()
    }
    
    // MARK: - func
    
    private func bindViewModel() {
        let output = self.transformedOutput()
        self.configureNavigation()
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> RecommendViewModel.Output? {
        guard let viewModel = self.viewModel as? RecommendViewModel else { return nil }
        let input = RecommendViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            scrolledToBottom: self.followView.collectionView().scrolledToBottomPublisher.eraseToAnyPublisher(),
            followMember: self.followButtonDidTapPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: RecommendViewModel.Output?) {
        guard let output else { return }
        
        output.members
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let followings):
                    self?.loadFollowings(followings)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.moreMembers
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let followings):
                    self?.loadMoreFollowings(followings)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.followMember
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let memberId):
                    self?.updateFollowing(memberId: memberId)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
    }
    
    private func bindCell(_ cell: UserInfoCollectionViewCell, with item: Member) {
        cell.followButtonTapAction = { [weak self] _ in
            self?.followButtonDidTapPublisher.send((item.id, item.isFollowing))
        }
    }
    
    // MARK: - func
    
    private func configureNavigation() {
        self.title = "추천 친구"
    }
}

// MARK: - DataSource
extension RecommendViewController {
    private func configureDataSource() {
        self.dataSource = self.userInfoCollectionViewDataSource()
        self.configureSnapshot()
    }

    private func userInfoCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Section, Member> {
        let reviewCellRegistration = UICollectionView.CellRegistration<UserInfoCollectionViewCell, Member> {
            [weak self] cell, indexPath, item in
            guard let self = self else { return }
            cell.configureCell(item)
            cell.cellTapAction = { _ in
                self.presentMemberViewController(id: item.id)
            }
            self.bindCell(cell, with: item)
        }

        return UICollectionViewDiffableDataSource(
            collectionView: self.followView.collectionView(),
            cellProvider: { collectionView, indexPath, item in
                return collectionView.dequeueConfiguredReusableCell(
                    using: reviewCellRegistration,
                    for: indexPath,
                    item: item
                )
            }
        )
    }
}

// MARK: - Snapshot
extension RecommendViewController {
    private func configureSnapshot() {
        self.snapshot = NSDiffableDataSourceSnapshot<Section, Member>()
        self.snapshot.appendSections([.main])
        self.dataSource.apply(self.snapshot, animatingDifferences: true)
    }

    private func loadFollowings(_ items: [Member]) {
        self.snapshot.appendItems(items, toSection: .main)
        self.dataSource.applySnapshotUsingReloadData(self.snapshot) {
            if self.snapshot.numberOfItems == 0 {
                self.followView.collectionView().backgroundView = self.emptyMemberView
            } else {
                self.followView.collectionView().backgroundView = nil
            }
        }
    }
    
    private func loadMoreFollowings(_ items: [Member]) {
        self.snapshot.appendItems(items, toSection: .main)
        self.dataSource.applySnapshotUsingReloadData(self.snapshot)
    }
    
    private func updateFollowing(memberId: Int) {
        let previousData = self.snapshot.itemIdentifiers(inSection: .main)
        let items = previousData
            .map { customItem in
                var updatedItem = customItem
                if customItem.id == memberId {
                    updatedItem.isFollowing.toggle()
                }
                return updatedItem
            }
        self.snapshot.deleteItems(previousData)
        self.snapshot.appendItems(items)
        self.dataSource.applySnapshotUsingReloadData(self.snapshot)
    }
}
