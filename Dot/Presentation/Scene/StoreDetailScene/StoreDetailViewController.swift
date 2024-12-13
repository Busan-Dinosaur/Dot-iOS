//
//  StoreDetailViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/18.
//

import Combine
import UIKit

import SnapKit
import Then

final class StoreDetailViewController: UIViewController, Navigationable {
    
    enum Section: CaseIterable {
        case main
    }
    
    // MARK: - ui component
    
    private let storeDetailView: StoreDetailView = StoreDetailView()
    private let emptyReviewView = EmptyListView().then {
        $0.configureEmptyView(message: "해당 맛집에 후기가 없어요.")
    }
    
    // MARK: - property
    
    private let viewModel: any StoreDetailViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let removeButtonDidTapPublisher = PassthroughSubject<Int, Never>()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Review>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Review>!
    
    // MARK: - init
    
    init(viewModel: any StoreDetailViewModelType) {
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
        self.view = self.storeDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDataSource()
        self.bindViewModel()
        self.bindUI()
        self.setupNavigation()
    }
    
    // MARK: - func - bind
    
    private func bindViewModel() {
        let output = self.transformedOutput()
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> StoreDetailViewModel.Output? {
        guard let viewModel = self.viewModel as? StoreDetailViewModel else { return nil }
        let input = StoreDetailViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            bookmarkButtonDidTap: self.storeDetailView.storeInfo().bookmarkButtonDidTapPublisher.eraseToAnyPublisher(),
            removeButtonDidTap: self.removeButtonDidTapPublisher.eraseToAnyPublisher(),
            scrolledToBottom: self.storeDetailView.collectionView().scrolledToBottomPublisher.eraseToAnyPublisher(),
            refreshControl: self.storeDetailView.refreshPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: StoreDetailViewModel.Output?) {
        guard let output else { return }
        
        output.store
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let store):
                    self.storeDetailView.storeInfo().configureStore(store)
                case .failure(let error):
                    self.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.reviews
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let reviews):
                    self.loadReviews(reviews)
                    self.storeDetailView.refreshControl().endRefreshing()
                case .failure(let error):
                    self.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.moreReviews
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let reviews):
                    self.loadMoreReviews(reviews)
                case .failure(let error):
                    self.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.isBookmarked
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.storeDetailView.storeInfo().bookmarkToggle()
                case .failure(let error):
                    self.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.isRemoved
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.viewModel.dismiss()
                case .failure(let error):
                    self.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
    }
    
    private func bindCell(_ cell: FeedNSCollectionViewCell, with item: Review) {
        cell.cellDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.viewModel.presentReviewDetailViewController(id: item.comment.id)
            }
            .store(in: &cell.cancellable)
        
        cell.userInfoButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.viewModel.presentMemberViewController(id: item.member.id)
            }
            .store(in: &cell.cancellable)
        
        cell.userInfo().optionButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                if item.member.isMyProfile {
                    self.viewModel.presentMyReviewOptionAlert(
                        onUpdate: {
                            self.viewModel.presentUpdateReviewViewController(reviewId: item.comment.id)
                        },
                        onDelete: {
                            self.removeButtonDidTapPublisher.send(item.comment.id)
                        }
                    )
                } else {
                    self.viewModel.presentReviewOptionAlert(
                        onBlame: {
                            self.viewModel.presentBlameViewController(
                                targetId: item.store.id,
                                blameTarget: "REVIEW"
                            )
                        }
                    )
                }
            }
            .store(in: &cell.cancellable)
    }
    
    private func bindUI() {
        self.storeDetailView.storeInfo().mapButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] url in
                guard let self = self else { return }
                self.viewModel.presentShowWebViewController(url: url)
            })
            .store(in: &self.cancellable)
    }
}

// MARK: - DataSource
extension StoreDetailViewController {
    
    private func configureDataSource() {
        self.dataSource = self.feedNSCollectionViewDataSource()
        self.configureSnapshot()
    }
    
    private func feedNSCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Section, Review> {
        let reviewCellRegistration = UICollectionView.CellRegistration<FeedNSCollectionViewCell, Review> {
            [weak self] cell, indexPath, item in
            cell.configureCell(item)
            self?.bindCell(cell, with: item)
        }
        
        return UICollectionViewDiffableDataSource(
            collectionView: self.storeDetailView.collectionView(),
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
extension StoreDetailViewController {
    
    private func configureSnapshot() {
        self.snapshot = NSDiffableDataSourceSnapshot<Section, Review>()
        self.snapshot.appendSections([.main])
        self.dataSource.apply(self.snapshot, animatingDifferences: true)
    }
    
    private func loadReviews(_ items: [Review]) {
        let previousReviewsData = self.snapshot.itemIdentifiers(inSection: .main)
        self.snapshot.deleteItems(previousReviewsData)
        self.snapshot.appendItems(items, toSection: .main)
        self.dataSource.applySnapshotUsingReloadData(self.snapshot) {
            if self.snapshot.numberOfItems == 0 {
                self.storeDetailView.collectionView().backgroundView = self.emptyReviewView
            } else {
                self.storeDetailView.collectionView().backgroundView = nil
            }
        }
    }
    
    private func loadMoreReviews(_ items: [Review]) {
        self.snapshot.appendItems(items, toSection: .main)
        self.dataSource.applySnapshotUsingReloadData(self.snapshot)
    }
    
    private func updateBookmark(_ storeId: Int) {
        let previousReviewsData = self.snapshot.itemIdentifiers(inSection: .main)
        let items = previousReviewsData
            .map { customItem in
                var updatedItem = customItem
                if customItem.store.id == storeId {
                    updatedItem.store.isBookmarked.toggle()
                }
                return updatedItem
            }
        self.snapshot.deleteItems(previousReviewsData)
        self.snapshot.appendItems(items)
        self.dataSource.applySnapshotUsingReloadData(self.snapshot)
    }
    
    private func deleteReview(_ reviewId: Int) {
        for item in snapshot.itemIdentifiers {
            if item.comment.id == reviewId {
                self.snapshot.deleteItems([item])
                self.dataSource.apply(self.snapshot)
                return
            }
        }
    }
}