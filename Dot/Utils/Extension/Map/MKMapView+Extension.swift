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
        self.mapType = MKMapType.standard
        self.showsUserLocation = true
        self.setUserTrackingMode(.follow, animated: true)
        self.isZoomEnabled = true
        self.showsCompass = false
        self.register(
            MapItemAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        self.register(
            ClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )
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
