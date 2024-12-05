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
    
    let categoryListView = CategoryListView()

    let mapView = MKMapView()
    
    lazy var trackingButton = MKUserTrackingButton(mapView: mapView).then {
        $0.layer.backgroundColor = UIColor.mainBackgroundColor.cgColor
        $0.layer.borderColor = UIColor.grey002.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.tintColor = UIColor.mainPink
    }
    
    let bookmarkButton = BookmarkMapButton().then {
        $0.layer.backgroundColor = UIColor.mainBackgroundColor.cgColor
        $0.layer.borderColor = UIColor.grey002.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    var feedListView = FeedListView()
    
    private lazy var modalView = ModalView(states: [100, self.fullViewHeight * 0.5, self.modalMaxHeight]).then {
        $0.setContentView(self.feedListView)
    }
    
    // MARK: - property
    
    let locationPublisher = PassthroughSubject<CustomLocationRequestDTO, Never>()
    let bookmarkToggleButtonDidTapPublisher = PassthroughSubject<Bool, Never>()
    let bookmarkButtonDidTapPublisher = PassthroughSubject<(Int, Bool), Never>()
    
    private let fullViewHeight: CGFloat = UIScreen.main.bounds.height
        
    lazy var modalMaxHeight: CGFloat = UIScreen.main.bounds.height - SizeLiteral.topAreaPadding - 100 // 100말고 nav높이 가져와야함

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
            self.mapView,
            self.trackingButton,
            self.bookmarkButton
        )
        
        self.categoryListView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        self.mapView.snp.makeConstraints {
            $0.top.equalTo(self.categoryListView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
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

        self.modalView.attach(to: self, initialStateIndex: 0)
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
        self.mapView.configureDefaultSettings()
        self.mapView.delegate = self
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
