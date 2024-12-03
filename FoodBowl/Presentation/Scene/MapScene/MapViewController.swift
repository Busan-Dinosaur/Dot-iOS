//
//  MapViewController.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import Combine
import UIKit

import SnapKit
import Then

final class MapViewController: UIViewController {
    
    // MARK: - ui component
    
    private let mapView: MapView = MapView()
    
    // MARK: - property
    
    private let viewModel: any MapViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
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
        self.bindViewModel()
    }

    // MARK: - func
    
    private func bindViewModel() {
        let output = self.transformedOutput()
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> MapViewModel.Output? {
        guard let viewModel = self.viewModel as? MapViewModel else { return nil }
        let input = MapViewModel.Input(
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: MapViewModel.Output?) {
        guard let output else { return }
    }
}
