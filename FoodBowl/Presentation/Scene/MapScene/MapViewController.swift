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
    
    // MARK: - ui component
    
    private let mapView: MapView = MapView()
    
    private let titleLabel = PaddingLabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .bold)
        $0.textColor = .mainTextColor
        $0.text = "푸드볼"
        $0.padding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        $0.frame = CGRect(x: 0, y: 0, width: 150, height: 0)
    }
    
    // MARK: - property
    
    private let viewModel: any MapViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    private var markers: [Marker] = []
    
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
        self.bindViewModel()
    }

    // MARK: - func
    
    private func configureNavigation() {
        let titleLabel = makeBarButtonItem(with: self.titleLabel)
        self.navigationItem.leftBarButtonItem = titleLabel
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
            setCategory: self.mapView.categoryListView.setCategoryPublisher.eraseToAnyPublisher(),
            customLocation: self.mapView.locationPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: MapViewModel.Output?) {
        guard let output else { return }
        
        output.stores
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let stores):
                    self?.setupMarkers(stores)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
    }
}

extension MapViewController {
    func setupMarkers(_ stores: [Store]) {
        self.mapView.mapView.removeAnnotations(self.markers)

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
//                    self?.presentStoreDetailViewController(id: store.id)
                }
            )
        }

        self.mapView.mapView.addAnnotations(self.markers)
    }
}
