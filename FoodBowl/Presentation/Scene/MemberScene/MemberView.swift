//
//  MemberView.swift
//  FoodBowl
//
//  Created by Coby on 12/8/24.
//

import Combine
import UIKit
import MapKit

import SnapKit
import Then

final class MemberView: UIView, BaseViewType {
    
    // MARK: - ui component
    
    private let optionButton = OptionButton()
    private let memberProfileView = MemberProfileView()
    private let categoryListView = CategoryListView()
    
    private let mkMapView = MKMapView()
    
    private let feedListView = FeedListView()
    private lazy var modalView = ModalView(states: [100, self.fullViewHeight * 0.5, self.modalMaxHeight]).then {
        $0.setContentView(self.feedListView)
    }
    
    // MARK: - property
    
    let locationPublisher = PassthroughSubject<CustomLocationRequestDTO, Never>()
    var optionButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.optionButton.buttonTapPublisher
    }
    
    private var previousCenter: CLLocationCoordinate2D?
    private var previousSpan: MKCoordinateSpan?
    
    private let fullViewHeight: CGFloat = UIScreen.main.bounds.height
    private lazy var modalMaxHeight: CGFloat = self.fullViewHeight - SizeLiteral.topAreaPadding - 44 - 40 - 60

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
            self.memberProfileView,
            self.categoryListView,
            self.mkMapView
        )
        
        self.memberProfileView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.categoryListView.snp.makeConstraints {
            $0.top.equalTo(self.memberProfileView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.mkMapView.snp.makeConstraints {
            $0.top.equalTo(self.categoryListView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        self.modalView.attach(to: self, initialStateIndex: 0)
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
        self.mkMapView.configureDefaultSettings()
        self.mkMapView.delegate = self
    }
    
    // MARK: - func
    
    func configureNavigationBarItem(
        _ navigationController: UINavigationController,
        _ title: String = ""
    ) {
        guard let navigationItem = navigationController.topViewController?.navigationItem else { return }
        let optionButton = navigationController.makeBarButtonItem(with: self.optionButton)
        navigationItem.rightBarButtonItem = optionButton
        navigationItem.title = title
    }
    
    func profileView() -> MemberProfileView {
        self.memberProfileView
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

extension MemberView: MKMapViewDelegate {
    
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
