//
//  MemberViewController.swift
//  FoodBowl
//
//  Created by Coby on 12/8/24.
//

import Combine
import UIKit
import MapKit

import SnapKit
import Then

final class MemberViewController: UIViewController, Navigationable {
    
    enum Section: CaseIterable {
        case main
    }
    
    // MARK: - ui component
    
    private let memberView: MemberView = MemberView()
    private let emptyView = EmptyListView().then {
        $0.configureEmptyView(message: "해당 지역에 후기가 없어요.")
    }
    
    // MARK: - property
    
    private let viewModel: any MemberViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let bookmarkButtonDidTapPublisher: PassthroughSubject<(Int, Bool), Never> = PassthroughSubject()
    private let viewWillAppearPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private var markers: [Marker] = []
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Review>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Review>!
    
    // MARK: - init
    
    init(viewModel: any MemberViewModelType) {
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
        self.view = self.memberView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.configureDataSource()
        self.bindViewModel()
        self.bindUI()
    }

    // MARK: - func
    
    private func configureNavigation(_ title: String = "") {
        guard let navigationController = self.navigationController else { return }
        self.memberView.configureNavigationBarItem(navigationController, title)
    }
    
    // MARK: - func - bind
    
    private func bindViewModel() {
        let output = self.transformedOutput()
        self.configureNavigation()
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> MemberViewModel.Output? {
        guard let viewModel = self.viewModel as? MemberViewModel else { return nil }
        let input = MemberViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            viewWillAppear: self.viewWillAppearPublisher.eraseToAnyPublisher(),
            setCategory: self.memberView.categoryView().setCategoryPublisher.eraseToAnyPublisher(),
            followMember: self.memberView.profileView().followButtonDidTapPublisher.eraseToAnyPublisher(),
            customLocation: self.memberView.locationPublisher.eraseToAnyPublisher(),
            bookmarkButtonDidTap: self.bookmarkButtonDidTapPublisher.eraseToAnyPublisher(),
            scrolledToBottom: self.memberView.feedView().collectionView().scrolledToBottomPublisher.eraseToAnyPublisher(),
            refreshControl: self.memberView.feedView().refreshPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: MemberViewModel.Output?) {
        guard let output else { return }
        
        output.member
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let member):
                    guard let self = self else { return }
                    self.memberView.profileView().configureMember(member: member)
                    self.configureNavigation(member.nickname)
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
                case .success:
                    guard let self = self else { return }
                    self.memberView.profileView().followToggle()
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.stores
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let stores):
                    guard let self = self else { return }
                    self.setupMarkers(stores)
                    self.memberView.feedView().updateStoreCount(to: stores.count)
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
                    guard let self = self else { return }
                    self.loadReviews(reviews)
                    self.memberView.feedView().refreshControl().endRefreshing()
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
                case .success(let storeId):
                    self?.updateBookmark(storeId)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
    }
    
    private func bindCell(_ cell: FeedCollectionViewCell, with item: Review) {
        cell.cellDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.viewModel.presentReviewDetailViewController(id: item.comment.id)
            }
            .store(in: &cell.cancellable)
        
        cell.userInfoButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.viewModel.presentMemberViewController(id: item.member.id)
            }
            .store(in: &cell.cancellable)
        
        cell.storeInfoButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.viewModel.presentStoreDetailViewController(id: item.store.id)
            }
            .store(in: &cell.cancellable)
        
        cell.bookmarkButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.bookmarkButtonDidTapPublisher.send((item.store.id, item.store.isBookmarked))
            }
            .store(in: &cell.cancellable)
        
        cell.optionButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.viewModel.presentReviewOptionAlert(
                    onBlame: {
                        self?.viewModel.presentBlameViewController(
                            targetId: item.store.id,
                            blameTarget: "REVIEW"
                        )
                    }
                )
            }
            .store(in: &cell.cancellable)
    }
    
    private func bindUI() {
        self.memberView.optionButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.viewModel.presentReviewOptionAlert(
                    onBlame: {
                        self?.viewModel.presentMemberBlameViewController()
                    }
                )
            })
            .store(in: &self.cancellable)
        
        self.memberView.profileView().followerButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.viewModel.presentFollowerViewController()
            })
            .store(in: &self.cancellable)
        
        self.memberView.profileView().followingButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.viewModel.presentFollowingViewController()
            })
            .store(in: &self.cancellable)
    }
}

extension MemberViewController {
    func setupMarkers(_ stores: [Store]) {
        self.memberView.mapView().removeAnnotations(self.markers)

        self.markers = stores.map { store in
            Marker(
                title: store.name,
                subtitle: "\(store.reviewCount)개의 후기",
                coordinate: CLLocationCoordinate2D(
                    latitude: store.y,
                    longitude: store.x
                ),
                glyphImage: CategoryType(rawValue: store.category)?.icon,
                handler: { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        self?.viewModel.presentStoreDetailViewController(id: store.id)
                    }
                }
            )
        }

        self.memberView.mapView().addAnnotations(self.markers)
    }
}

extension MemberViewController {
    
    private func configureDataSource() {
        self.dataSource = self.feedCollectionViewDataSource()
        self.configureSnapshot()
    }

    private func feedCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Section, Review> {
        let reviewCellRegistration = UICollectionView.CellRegistration<FeedCollectionViewCell, Review> {
            [weak self] cell, indexPath, item in
            guard let self = self else { return }
            cell.configureCell(item)
            self.bindCell(cell, with: item)
        }

        return UICollectionViewDiffableDataSource(
            collectionView: self.memberView.feedView().collectionView(),
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
extension MemberViewController {
    
    private func configureSnapshot() {
        self.snapshot = NSDiffableDataSourceSnapshot<Section, Review>()
        self.snapshot.appendSections([.main])
        self.dataSource.apply(self.snapshot, animatingDifferences: true)
    }

    func loadReviews(_ items: [Review]) {
        let previousReviewsData = self.snapshot.itemIdentifiers(inSection: .main)
        self.snapshot.deleteItems(previousReviewsData)
        self.snapshot.appendItems(items, toSection: .main)
        self.dataSource.applySnapshotUsingReloadData(self.snapshot) {
            if self.snapshot.numberOfItems == 0 {
                self.memberView.feedView().collectionView().backgroundView = self.emptyView
            } else {
                self.memberView.feedView().collectionView().backgroundView = nil
            }
        }
    }
    
    func loadMoreReviews(_ items: [Review]) {
        self.snapshot.appendItems(items, toSection: .main)
        self.dataSource.applySnapshotUsingReloadData(self.snapshot)
    }
    
    func updateBookmark(_ storeId: Int) {
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
    
    func deleteReview(_ reviewId: Int) {
        for item in snapshot.itemIdentifiers {
            if item.comment.id == reviewId {
                self.snapshot.deleteItems([item])
                self.dataSource.apply(self.snapshot)
                return
            }
        }
    }
}

