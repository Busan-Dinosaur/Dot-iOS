//
//  PhotoesSelectViewModel.swift
//  FoodBowl
//
//  Created by Coby on 12/6/24.
//

import Combine
import Foundation
import MapKit

final class PhotoesSelectViewModel: NSObject {
    
    // MARK: - property
    
    private let coordinator: PhotoesSelectCoordinator?
    
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
        coordinator: PhotoesSelectCoordinator?
    ) {
        self.coordinator = coordinator
    }
    
    // MARK: - func
}

extension PhotoesSelectViewModel: PhotoesSelectViewModelType {
    
    func dismiss() {
        self.coordinator?.dismiss()
    }
    
    func presentCreateReviewViewController(reviewImages: [UIImage], location: CLLocationCoordinate2D?) {
        self.coordinator?.presentCreateReviewViewController(reviewImages: reviewImages, location: location)
    }
}
