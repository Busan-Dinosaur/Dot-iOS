//
//  MKMapView+Extension.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import MapKit

extension MKMapView {
    /// 기본 지도 설정
    func configureDefaultSettings() {
        self.mapType = .standard // 지도 타입
        self.showsUserLocation = true // 사용자 위치 표시
        self.isZoomEnabled = true // 줌 활성화
        self.isScrollEnabled = true // 스크롤 활성화
    }
    
    /// 특정 좌표로 초기 위치 설정
    func setRegion(
        latitude: CLLocationDegrees,
        longitude: CLLocationDegrees,
        span: Double,
        animated: Bool = true
    ) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        )
        self.setRegion(region, animated: animated)
    }
}
