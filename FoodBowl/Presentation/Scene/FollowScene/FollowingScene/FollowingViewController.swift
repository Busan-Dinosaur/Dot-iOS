//
//  FollowingViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/19.
//

import Combine
import UIKit

import SnapKit
import Then

final class FollowingViewController: UIViewController, Navigationable, Helperable {
    
    enum Section: CaseIterable {
        case main
    }
    
    // MARK: - ui component
    
    private let followView: FollowView = FollowView()
    
    // MARK: - property
    
    private let viewModel: any BaseViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Member>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Member>!
    
    private let followButtonDidTapPublisher = PassthroughSubject<(Int, Bool), Never>()
    
    // MARK: - init
    
    init(viewModel: FollowingViewModel) {
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
    
    private func transformedOutput() -> FollowingViewModel.Output? {
        guard let viewModel = self.viewModel as? FollowingViewModel else { return nil }
        let input = FollowingViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            scrolledToBottom: self.followView.collectionView().scrolledToBottomPublisher.eraseToAnyPublisher(),
            followMember: self.followButtonDidTapPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: FollowingViewModel.Output?) {
        guard let output else { return }
        
        output.followings
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
        
        output.moreFollowings
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
        self.title = "팔로잉"
    }
}

// MARK: - DataSource
extension FollowingViewController {
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
extension FollowingViewController {
    private func configureSnapshot() {
        self.snapshot = NSDiffableDataSourceSnapshot<Section, Member>()
        self.snapshot.appendSections([.main])
        self.dataSource.apply(self.snapshot, animatingDifferences: true)
    }

    private func loadFollowings(_ items: [Member]) {
        self.snapshot.appendItems(items, toSection: .main)
        self.dataSource.applySnapshotUsingReloadData(self.snapshot) {
            if self.snapshot.numberOfItems == 0 {
                guard let viewModel = self.viewModel as? FollowingViewModel else { return }
                let emptyView = EmptyView(message: "팔로잉 중인 유저가 없어요.", isFind: viewModel.isOwn)
                emptyView.findButtonTapAction = { [weak self] _ in
                    self?.presentRecommendViewController()
                }
                
                self.followView.collectionView().backgroundView = emptyView
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
    
    private func removeFollowing(memberId: Int) {
        for item in snapshot.itemIdentifiers {
            if item.id == memberId {
                self.snapshot.deleteItems([item])
                self.dataSource.apply(self.snapshot)
                return
            }
        }
    }
}
