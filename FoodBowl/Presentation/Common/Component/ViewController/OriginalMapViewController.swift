//
//  OriginalMapViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/10.
//

import Combine
import CoreLocation
import MapKit
import UIKit

import SnapKit
import Then

class OriginalMapViewController: UIViewController, Navigationable, Optionable, Helperable {
    
    enum Section: CaseIterable {
        case main
    }
    
    // MARK: - ui component
    
    let plusButton = PlusButton()
    lazy var mapView = MKMapView().then {
        $0.delegate = self
        $0.mapType = MKMapType.standard
        $0.showsUserLocation = true
        $0.setUserTrackingMode(.follow, animated: true)
        $0.isZoomEnabled = true
        $0.showsCompass = false
        $0.register(
            MapItemAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        $0.register(
            ClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )
    }
    lazy var trackingButton = MKUserTrackingButton(mapView: mapView).then {
        $0.layer.backgroundColor = UIColor.mainBackgroundColor.cgColor
        $0.layer.borderColor = UIColor.grey002.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.tintColor = UIColor.mainColor
    }
    let bookmarkButton = BookmarkMapButton().then {
        $0.layer.backgroundColor = UIColor.mainBackgroundColor.cgColor
        $0.layer.borderColor = UIColor.grey002.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.isHidden = true
    }
    let myPlaceButton = MyPlaceButton().then {
        $0.layer.backgroundColor = UIColor.mainBackgroundColor.cgColor
        $0.layer.borderColor = UIColor.grey002.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.isHidden = true
    }
    let categoryListView = CategoryListView()
    let grabbarView = GrabbarView()
    let feedListView = FeedListView()
    lazy var emptyView = EmptyView(message: "해당 지역에 후기가 없어요.").then {
        $0.findButtonTapAction = { [weak self] _ in
            self?.presentRecommendViewController()
        }
    }
    
    // MARK: - property
    
    let isOwn: Bool
    var markers: [Marker] = []
    
    let viewModel: any BaseViewModelType
    var cancellable: Set<AnyCancellable> = Set()
    
    let locationPublisher = PassthroughSubject<CustomLocationRequestDTO, Never>()
    let followButtonDidTapPublisher = PassthroughSubject<(Int, Bool), Never>()
    let bookmarkToggleButtonDidTapPublisher = PassthroughSubject<Bool, Never>()
    let bookmarkButtonDidTapPublisher = PassthroughSubject<(Int, Bool), Never>()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Review>!
    var snapshot: NSDiffableDataSourceSnapshot<Section, Review>!
    
    // MARK: - Modal Values
    
    private var modalMinHeight: CGFloat = 40
    private var modalMidHeight: CGFloat = UIScreen.main.bounds.height / 2 - 100
    lazy var modalMaxHeight: CGFloat = UIScreen.main.bounds.height - SizeLiteral.topAreaPadding - navBarHeight - 120
    
    private lazy var tabBarHeight: CGFloat = tabBarController?.tabBar.frame.height ?? 0
    private lazy var navBarHeight: CGFloat = navigationController?.navigationBar.frame.height ?? 0
    
    private var currentModalHeight: CGFloat = 0
    private var categoryListHeight: CGFloat = 40
    
    private var panGesture = UIPanGestureRecognizer()
    
    // MARK: - init
    
    init(
        viewModel: any BaseViewModelType,
        isOwn: Bool = false
    ) {
        self.viewModel = viewModel
        self.isOwn = isOwn
        super.init(nibName: nil, bundle: nil)
        self.setupLayout()
        self.configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(#file) is dead")
    }
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.configureDataSource()
        self.configureModal()
        self.setupModal()
        self.bindViewModel()
        self.bindUI()
        self.setupAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setModalState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.maxY - self.tabBarHeight)
    }
    
    // MARK: - func
    
    func setupLayout() {
        self.view.addSubviews(
            self.mapView,
            self.categoryListView,
            self.trackingButton,
            self.bookmarkButton,
            self.myPlaceButton,
            self.grabbarView,
            self.feedListView
        )
        
        self.mapView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        self.categoryListView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        self.trackingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(self.categoryListView.snp.bottom).offset(20)
            $0.height.width.equalTo(40)
        }
        
        self.bookmarkButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(self.trackingButton.snp.bottom).offset(8)
            $0.height.width.equalTo(40)
        }
        
        self.myPlaceButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(self.trackingButton.snp.bottom).offset(8)
            $0.height.width.equalTo(40)
        }
        
        self.grabbarView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        self.feedListView.snp.makeConstraints {
            $0.top.equalTo(self.grabbarView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(self.modalMidHeight)
        }
    }
    
    func configureUI() {
        self.view.backgroundColor = .mainBackgroundColor
    }
    
    // MARK: - func - bind
    
    func bindViewModel() { }
    
    func bindUI() { }
    
    private func bindCell(_ cell: FeedCollectionViewCell, with item: Review) {
        cell.userButtonTapAction = { [weak self] _ in
            self?.presentProfileViewController(id: item.member.id)
        }
        
        cell.optionButtonTapAction = { [weak self] _ in
            self?.presentReviewOptionAlert(
                reviewId: item.comment.id,
                isMyReview: item.member.isMyProfile
            )
        }
        
        cell.storeButtonTapAction = { [weak self] _ in
            self?.presentStoreDetailViewController(id: item.store.id)
        }
        
        cell.bookmarkButtonTapAction = { [weak self] _ in
            self?.bookmarkButtonDidTapPublisher.send((item.store.id, item.store.isBookmarked))
        }
        
        cell.cellTapAction = { [weak self] _ in
            self?.presentReviewDetailViewController(id: item.comment.id)
        }
    }
    
    // MARK: - func
    
    func configureModal() { }
    
    func setupModal() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.grabbarView.isUserInteractionEnabled = true
        self.grabbarView.addGestureRecognizer(panGesture)
        self.currentModalHeight = self.modalMidHeight
    }
    
    func setupAction() {
        let plusAction = UIAction { [weak self] _ in
            self?.presentPhotoesSelectViewController()
        }
        self.plusButton.addAction(plusAction, for: .touchUpInside)
        
        let bookmarkToggleAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.bookmarkToggleButtonDidTapPublisher.send(self.bookmarkButton.isSelected)
            self.bookmarkButton.isSelected.toggle()
        }
        self.bookmarkButton.addAction(bookmarkToggleAction, for: .touchUpInside)
    }
    
    func updateReview(reviewId: Int) { }
    
    func removeReview(reviewId: Int) { }
}

// MARK: - Markers
extension OriginalMapViewController {
    func setupMarkers(_ stores: [Store]) {
        self.mapView.removeAnnotations(self.markers)

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
                    self?.presentStoreDetailViewController(id: store.id)
                }
            )
        }

        self.mapView.addAnnotations(self.markers)
        self.grabbarView.modalResultLabel.text = "\(stores.count.prettyNumber)개의 맛집"
    }
}

// MARK: - DataSource
extension OriginalMapViewController {
    private func configureDataSource() {
        self.dataSource = self.feedCollectionViewDataSource()
        self.configureSnapshot()
    }

    private func feedCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Section, Review> {
        let reviewCellRegistration = UICollectionView.CellRegistration<FeedCollectionViewCell, Review> {
            [weak self] cell, indexPath, item in
            guard let self = self else { return }
            cell.configureCell(item, self.isOwn)
            self.bindCell(cell, with: item)
        }

        return UICollectionViewDiffableDataSource(
            collectionView: self.feedListView.collectionView(),
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
extension OriginalMapViewController {
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
                self.feedListView.collectionView().backgroundView = self.emptyView
            } else {
                self.feedListView.collectionView().backgroundView = nil
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

extension OriginalMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard view is ClusterAnnotationView else { return }

        let currentSpan = mapView.region.span
        let zoomSpan = MKCoordinateSpan(
            latitudeDelta: currentSpan.latitudeDelta / 3.0,
            longitudeDelta: currentSpan.longitudeDelta / 3.0
        )
        let zoomCoordinate = view.annotation?.coordinate ?? mapView.region.center
        let zoomed = MKCoordinateRegion(center: zoomCoordinate, span: zoomSpan)
        mapView.setRegion(zoomed, animated: true)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        if let currentLocation = LocationManager.shared.manager.location?.coordinate {
            let visibleMapRect = mapView.visibleMapRect
            let topLeftCoordinate = MKMapPoint(x: visibleMapRect.minX, y: visibleMapRect.minY).coordinate
            let customLocation = CustomLocationRequestDTO(
                x: center.longitude,
                y: center.latitude,
                deltaX: abs(topLeftCoordinate.longitude - center.longitude),
                deltaY: abs(topLeftCoordinate.latitude - center.latitude),
                deviceX: currentLocation.longitude,
                deviceY: currentLocation.latitude
            )
            
            self.locationPublisher.send(customLocation)
        }
    }
}

// MARK: - Control Modal
extension OriginalMapViewController {
    @objc
    func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.view != nil else { return }
        let translation = gesture.translation(in: gesture.view?.superview)
        
        var newModalHeight = self.currentModalHeight - translation.y
        switch newModalHeight {
        case ...self.modalMinHeight:
            newModalHeight = self.modalMinHeight
            self.setModalMinState()
        case ...self.modalMaxHeight:
            self.setModalMidState()
        default:
            newModalHeight = modalMaxHeight
            self.setModalMaxState()
        }

        self.feedListView.snp.remakeConstraints {
            $0.top.equalTo(self.grabbarView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(newModalHeight)
        }

        if gesture.state == .ended {
            switch newModalHeight {
            case let height where height - self.modalMinHeight < self.modalMidHeight - height:
                self.currentModalHeight = self.modalMinHeight
            case let height where height - self.modalMidHeight < self.modalMaxHeight - height:
                self.currentModalHeight = self.modalMidHeight
            default:
                self.currentModalHeight = self.modalMaxHeight
            }
            
            self.setModalState()

            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut,
                animations: {
                    self.feedListView.snp.updateConstraints {
                        $0.top.equalTo(self.grabbarView.snp.bottom)
                        $0.leading.trailing.bottom.equalToSuperview()
                        $0.height.equalTo(self.currentModalHeight)
                    }
                    self.feedListView.superview?.layoutIfNeeded()
                }
            )
        }
    }
    
    private func setModalState() {
        switch self.currentModalHeight {
        case self.modalMinHeight:
            self.setModalMinState()
        case self.modalMidHeight:
            self.setModalMidState()
        default:
            self.setModalMaxState()
        }
    }

    private func setModalMinState() {
        self.grabbarView.showResult()
        self.feedListView.collectionView().isHidden = true
        self.tabBarController?.tabBar.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.maxY)
    }

    private func setModalMidState() {
        self.grabbarView.layer.cornerRadius = 15
        self.grabbarView.showContent()
        self.feedListView.collectionView().isHidden = false
        self.tabBarController?.tabBar.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.maxY - self.tabBarHeight)
    }

    private func setModalMaxState() {
        self.grabbarView.layer.cornerRadius = 0
    }
}
