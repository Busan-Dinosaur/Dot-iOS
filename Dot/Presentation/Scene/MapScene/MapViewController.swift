//
//  MapViewController.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import Combine
import UIKit
import MapKit

import SnapKit
import Then

final class MapViewController: UIViewController, Navigationable {
    
    enum Section: CaseIterable {
        case main
    }
    
    // MARK: - ui component
    
    private let mapView: MapView = MapView()
    private let emptyReviewView = EmptyListView().then {
        $0.configureEmptyView(message: "해당 지역에 후기가 없어요.")
    }
    
    // MARK: - property
    
    private let viewModel: any MapViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let removeButtonDidTapPublisher = PassthroughSubject<Int, Never>()
    private let bookmarkButtonDidTapPublisher: PassthroughSubject<(Int, Bool), Never> = PassthroughSubject()
    private let switchPublisher = PassthroughSubject<SwitchType, Never>()
    
    private var markers: [Marker] = []
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Review>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Review>!
    
    // MARK: - init
    
    init(viewModel: any MapViewModelType) {
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
        self.view = self.mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.configureDataSource()
        self.bindViewModel()
        self.bindUI()
    }

    // MARK: - func
    
    private func configureNavigation() {
        guard let navigationController = self.navigationController else { return }
        self.mapView.configureNavigationBarItem(navigationController)
    }
    
    // MARK: - func - bind
    
    private func bindViewModel() {
        let output = self.transformedOutput()
        self.configureNavigation()
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> MapViewModel.Output? {
        guard let viewModel = self.viewModel as? MapViewModel else { return nil }
        let input = MapViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            setCategory: self.mapView.categoryView().setCategoryPublisher.eraseToAnyPublisher(),
            customLocation: self.mapView.locationPublisher.eraseToAnyPublisher(),
            switchButtonDidTap: self.switchPublisher.eraseToAnyPublisher(),
            bookmarkButtonDidTap: self.bookmarkButtonDidTapPublisher.eraseToAnyPublisher(),
            removeButtonDidTap: self.removeButtonDidTapPublisher.eraseToAnyPublisher(),
            scrolledToBottom: self.mapView.feedView().collectionView().scrolledToBottomPublisher.eraseToAnyPublisher(),
            refreshControl: self.mapView.feedView().refreshPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: MapViewModel.Output?) {
        guard let output else { return }
        
        output.stores
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let stores):
                    self.setupMarkers(stores)
                    self.mapView.feedView().updateStoreCount(to: stores.count)
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
                    self.mapView.feedView().refreshControl().endRefreshing()
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
                case .success(let storeId):
                    self.updateBookmark(storeId)
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
                  case .success(let reviewId):
                      self.deleteReview(reviewId)
                  case .failure(let error):
                      self.makeErrorAlert(
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
        
        cell.storeInfoButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.viewModel.presentStoreDetailViewController(id: item.store.id)
            }
            .store(in: &cell.cancellable)
        
        cell.bookmarkButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.bookmarkButtonDidTapPublisher.send((item.store.id, item.store.isBookmarked))
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
        self.mapView.searchBarButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.presentFindViewController()
            })
            .store(in: &self.cancellable)
        
        self.mapView.plusButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.presentPhotoesSelectViewController()
            })
            .store(in: &self.cancellable)
        
        self.mapView.settingButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.presentSettingViewController()
            })
            .store(in: &self.cancellable)
        
        self.mapView.switchButton.switchButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                let nextType = self.mapView.switchButton.currentSwitchType.nextType
                self.mapView.switchButton.currentSwitchType = nextType
                self.switchPublisher.send(nextType)
            })
            .store(in: &self.cancellable)
        
        self.emptyReviewView.findButtonTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.presentRecommendViewController()
            })
            .store(in: &self.cancellable)
    }
}

extension MapViewController {
    func setupMarkers(_ stores: [Store]) {
        self.mapView.mapView().removeAnnotations(self.markers)

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

        self.mapView.mapView().addAnnotations(self.markers)
    }
}

// MARK: - DataSource
extension MapViewController {
    
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
            collectionView: self.mapView.feedView().collectionView(),
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
extension MapViewController {
    
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
                self.mapView.feedView().collectionView().backgroundView = self.emptyReviewView
            } else {
                self.mapView.feedView().collectionView().backgroundView = nil
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

