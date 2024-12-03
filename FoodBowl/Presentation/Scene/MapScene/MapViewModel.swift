//
//  MapViewModel.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import Combine
import Foundation

final class MapViewModel: NSObject, MapViewModelType {
    
    // MARK: - property
    
    private let usecase: MapUsecase
    private let coordinator: MapCoordinator?
    private var cancellable: Set<AnyCancellable> = Set()
    
    struct Input {
    }
    
    struct Output {
    }
    
    func transform(from input: Input) -> Output {
        return Output(
        )
    }
    
    // MARK: - init
    
    init(
        usecase: MapUsecase,
        coordinator: MapCoordinator?
    ) {
        self.usecase = usecase
        self.coordinator = coordinator
    }
    
    // MARK: - func
}
