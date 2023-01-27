//
//  MapViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/10.
//

import UIKit

import CoreLocation
import MapKit
import SnapKit
import Then

final class MapViewController: BaseViewController {
    private enum Size {
        static let collectionInset = UIEdgeInsets(top: 0,
                                                  left: 20,
                                                  bottom: 0,
                                                  right: 20)
    }

    private let categories = Category.allCases

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        manager.delegate = self
        return manager
    }()

    private lazy var mapView = MKMapView().then {
        $0.delegate = self
        $0.mapType = MKMapType.standard
        $0.showsUserLocation = true
        $0.setUserTrackingMode(.follow, animated: true)
        $0.isZoomEnabled = true
        $0.showsCompass = false
    }

    private lazy var searchBarButton = SearchBarButton().then {
        $0.label.text = "친구들의 후기를 찾아보세요."
        let action = UIAction { [weak self] _ in
            let findStoreViewController = FindStoreViewController()
            let navigationController = UINavigationController(rootViewController: findStoreViewController)
            navigationController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                self?.present(navigationController, animated: true)
            }
        }
        $0.addAction(action, for: .touchUpInside)
    }

    private let collectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.sectionInset = Size.collectionInset
        $0.minimumLineSpacing = 4
        $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }

    private lazy var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout).then {
        $0.backgroundColor = .clear
        $0.dataSource = self
        $0.delegate = self
        $0.showsHorizontalScrollIndicator = false
        $0.allowsMultipleSelection = true
        $0.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.className)
    }

    private lazy var gpsButton = UIButton().then {
        $0.backgroundColor = .white
        $0.makeBorderLayer(color: .grey002)
        $0.setImage(ImageLiteral.btnGps, for: .normal)
        $0.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let action = UIAction { [weak self] _ in
            self?.findMyLocation()
        }
        $0.addAction(action, for: .touchUpInside)
    }

    private lazy var bookMarkButton = UIButton().then {
        $0.backgroundColor = .white
        $0.makeBorderLayer(color: .grey002)
        $0.setImage(ImageLiteral.btnBookmark, for: .normal)
        $0.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let action = UIAction { [weak self] _ in
        }
        $0.addAction(action, for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        findMyLocation()
        setMarkers()
        mapView.delegate = self
    }

    override func viewWillDisappear(_: Bool) {
        locationManager.stopUpdatingLocation()
    }

    override func render() {
        view.addSubviews(mapView, searchBarButton, listCollectionView, gpsButton, bookMarkButton)

        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        searchBarButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }

        listCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchBarButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        gpsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.height.width.equalTo(50)
        }

        bookMarkButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(gpsButton.snp.top).offset(-10)
            $0.height.width.equalTo(50)
        }
    }

    override func setupNavigationBar() {
        navigationController?.isNavigationBarHidden = true
    }

    private func getLocationUsagePermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    private func findMyLocation() {
        guard let currentLocation = locationManager.location else {
            getLocationUsagePermission()
            return
        }

        mapView.setRegion(MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
    }

    private func setMarkers() {
        guard let currentLocation = locationManager.location else {
            getLocationUsagePermission()
            return
        }

        let marks: [Marker] = [
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "일식",
                coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude + 0.001, longitude: currentLocation.coordinate.longitude + 0.001)
            ),
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "3개의 후기",
                coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude + 0.001, longitude: currentLocation.coordinate.longitude + 0.002)
            ),
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "3개의 후기",
                coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude + 0.001, longitude: currentLocation.coordinate.longitude + 0.003)
            ),
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "3개의 후기",
                coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude + 0.001, longitude: currentLocation.coordinate.longitude + 0.004)
            ),
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "3개의 후기",
                coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude + 0.001, longitude: currentLocation.coordinate.longitude + 0.005)
            ),
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "3개의 후기",
                coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude + 0.002, longitude: currentLocation.coordinate.longitude + 0.001)
            ),
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "3개의 후기",
                coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude + 0.001, longitude: currentLocation.coordinate.longitude + 0.002)
            ),
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "3개의 후기",
                coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude + 0.001, longitude: currentLocation.coordinate.longitude + 0.003)
            ),
            Marker(
                title: "홍대입구역 편의점",
                subtitle: "3개의 후기",
                coordinate: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude + 0.001, longitude: currentLocation.coordinate.longitude + 0.004)
            )
        ]

        marks.forEach { mark in
            mapView.addAnnotation(mark)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            DispatchQueue.main.async {
                self.getLocationUsagePermission()
            }
        case .denied:
            print("GPS 권한 요청 거부됨")
            DispatchQueue.main.async {
                self.getLocationUsagePermission()
            }
        default:
            print("GPS: Default")
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    // 1
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? Marker else {
            return nil
        }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier) as? MKMarkerAnnotationView
        {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier
            )
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: 0, y: 5)

            let feedButton = FeedButton().then {
                let action = UIAction { [weak self] _ in
                    let storeFeedViewController = StoreFeedViewController(isMap: true)
                    let navigationController = UINavigationController(rootViewController: storeFeedViewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    DispatchQueue.main.async {
                        self?.present(navigationController, animated: true)
                    }
                }
                $0.addAction(action, for: .touchUpInside)
            }
            view.rightCalloutAccessoryView = feedButton
        }
        return view
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.className, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.layer.cornerRadius = 20
        cell.categoryLabel.text = categories[indexPath.item].rawValue

        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(categories[indexPath.item].rawValue)
    }
}
