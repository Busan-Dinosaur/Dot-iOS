//
//  MapView.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import Combine
import UIKit
import MapKit

import SnapKit
import Then

final class MapView: UIView, BaseViewType {
    
    // MARK: - ui component
    
    private let searchBarButton = SearchBarButton().then {
        $0.setPlaceholder(title: "둘러보기")
    }
    private let plusButton = PlusButton()
    private let settingButton = SettingButton()
    private let categoryListView = CategoryListView()
    
    private let mkMapView = MKMapView()
    let switchButton = SwitchButton()
    private lazy var trackingButton = MKUserTrackingButton(mapView: self.mkMapView).then {
        $0.layer.backgroundColor = UIColor.mainBackgroundColor.cgColor
        $0.layer.borderColor = UIColor.grey002.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.tintColor = UIColor.mainColor
    }
    
    private let feedListView = FeedListView()
    private lazy var modalView = ModalView(states: [100, self.fullViewHeight * 0.5, self.modalMaxHeight]).then {
        $0.setContentView(self.feedListView)
    }
    
    // MARK: - property
    
    let locationPublisher = PassthroughSubject<CustomLocationRequestDTO, Never>()
    var searchBarButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.searchBarButton.buttonTapPublisher
    }
    var plusButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.plusButton.buttonTapPublisher
    }
    var settingButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.settingButton.buttonTapPublisher
    }
    
    private var previousCenter: CLLocationCoordinate2D?
    private var previousSpan: MKCoordinateSpan?
    
    private let fullViewHeight: CGFloat = UIScreen.main.bounds.height
    private lazy var modalMaxHeight: CGFloat = self.fullViewHeight - SizeLiteral.topAreaPadding - 44 - 48

    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(
            self.categoryListView,
            self.mkMapView,
            self.switchButton,
            self.trackingButton
        )
        
        self.categoryListView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.mkMapView.snp.makeConstraints {
            $0.top.equalTo(self.categoryListView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        self.switchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(self.categoryListView.snp.bottom).offset(20)
            $0.height.width.equalTo(40)
        }
        
        self.trackingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(self.switchButton.snp.bottom).offset(8)
            $0.height.width.equalTo(40)
        }

        self.modalView.attach(to: self, initialStateIndex: 0)
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
        self.mkMapView.configureDefaultSettings()
        self.mkMapView.delegate = self
        self.switchButton.currentSwitchType = .all
    }
    
    // MARK: - func
    
    func configureNavigationBarItem(_ navigationController: UINavigationController) {
        guard let navigationItem = navigationController.topViewController?.navigationItem else { return }
        
        let plusButton = navigationController.makeBarButtonItem(with: self.plusButton)
        let settingButton = navigationController.makeBarButtonItem(with: self.settingButton)
        navigationItem.rightBarButtonItems = [settingButton, plusButton]
        
        let screenWidth = UIScreen.main.bounds.width
        let rightButtonsWidth: CGFloat = 30 * 2 + 16 * 3
        let leftButtonWidth = screenWidth - rightButtonsWidth - 8
        
        let searchContainerView = UIView().then {
            $0.addSubview(self.searchBarButton)
        }
        
        self.searchBarButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(4)
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(leftButtonWidth)
        }
        
        searchContainerView.snp.makeConstraints {
            $0.width.equalTo(leftButtonWidth)
        }
        
        let searchBarButtonItem = UIBarButtonItem(customView: searchContainerView)
        navigationItem.leftBarButtonItem = searchBarButtonItem
    }
    
    func categoryView() -> CategoryListView {
        self.categoryListView
    }
    
    func mapView() -> MKMapView {
        self.mkMapView
    }
    
    func feedView() -> FeedListView {
        self.feedListView
    }
}

extension MapView: MKMapViewDelegate {

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

        // 이전 좌표와 확대/축소 값을 저장할 프로퍼티
        if self.previousCenter == nil || self.previousSpan == nil {
            self.previousCenter = center
            self.previousSpan = mapView.region.span
        }

        // 확대/축소 여부 확인
        let currentSpan = mapView.region.span
        let isZooming = abs(currentSpan.latitudeDelta - self.previousSpan!.latitudeDelta) > 0.0001 ||
                        abs(currentSpan.longitudeDelta - self.previousSpan!.longitudeDelta) > 0.0001

        // 이전 좌표와 현재 좌표를 비교하여 큰 변화가 없는 경우, 줌 동작이 아니라면 return
        let threshold: CLLocationDegrees = 0.001 // 변경 감지 임계값
        let deltaX = abs(center.latitude - self.previousCenter!.latitude)
        let deltaY = abs(center.longitude - self.previousCenter!.longitude)

        if !isZooming && deltaX < threshold && deltaY < threshold {
            return
        }

        // 업데이트된 좌표와 확대/축소 값 저장
        self.previousCenter = center
        self.previousSpan = currentSpan

        // 현재 사용자 위치가 유효한 경우에만 전송
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
