//
//  MapUsecase.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import Foundation

protocol MapUsecase {
}

final class MapUsecaseImpl: MapUsecase {
    
    // MARK: - property
    
    private let repository: MapRepository
    
    // MARK: - init
    
    init(repository: MapRepository) {
        self.repository = repository
    }
    
    // MARK: - Public - func
}
