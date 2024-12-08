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

final class StoreDetailViewController: UIViewController, Navigationable, Optionable, Helperable {
    
    enum Section: CaseIterable {
        case main
    }
    
    // MARK: - ui component
    
    private let storeDetailView: StoreDetailView = StoreDetailView()
    
    // MARK: - property
    
    private var owner: String = "친구들"
    
    private let viewModel: any BaseViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Review>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Review>!

    // MARK: - init
    
    init(viewModel: any BaseViewModelType) {
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
            reviewToggleButtonDidTap: self.storeDetailView.reviewToggleButtonDidTapPublisher.eraseToAnyPublisher(),
            bookmarkButtonDidTap: self.storeDetailView.bookmarkButtonDidTapPublisher.eraseToAnyPublisher(),
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
                switch result {
                case .success(let store):
                    self?.storeDetailView.storeHeaderView.configureHeader(store)
                    self?.storeDetailView.storeHeaderView.mapButtonTapAction = { _ in
                        self?.presentShowWebViewController(url: store.url)
                    }
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.reviews
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let reviews):
                    self?.loadReviews(reviews)
                    self?.storeDetailView.refreshControl().endRefreshing()
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.moreReviews
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let reviews):
                    self?.loadMoreReviews(reviews)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.isBookmarked
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success:
                    self?.storeDetailView.storeHeaderView.bookmarkButton.isSelected.toggle()
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)        
    }
    
    private func bindUI() {
        self.storeDetailView.reviewToggleButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isFriend in
                self?.title = isFriend ? "친구들의 후기" : "모두의 후기"
                self?.owner = isFriend ? "친구들" : "모두"
            })
            .store(in: &self.cancellable)
    }
    
    private func bindCell(_ cell: FeedNSCollectionViewCell, with item: Review) {
        cell.userButtonTapAction = { [weak self] _ in
            self?.presentProfileViewController(id: item.member.id)
        }
        
        cell.optionButtonTapAction = { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.presentReviewOptionAlert(
                    reviewId: item.comment.id,
                    isMyReview: item.member.isMyProfile
                )
            }
        }
        
        cell.cellTapAction = { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.presentReviewDetailViewController(id: item.comment.id)
            }
        }
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
                let emptyView = EmptyView(message: "\(self.owner)의 후기가 없어요.")
                emptyView.findButtonTapAction = { [weak self] _ in
                    self?.presentRecommendViewController()
                }
                
                self.storeDetailView.collectionView().backgroundView = emptyView
            } else {
                self.storeDetailView.collectionView().backgroundView = nil
            }
        }
    }
    
    private func loadMoreReviews(_ items: [Review]) {
        self.snapshot.appendItems(items, toSection: .main)
        self.dataSource.applySnapshotUsingReloadData(self.snapshot)
    }
}
