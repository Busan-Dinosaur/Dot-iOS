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
    
    private let usecase: MyPlaceUsecase
    private let coordinator: MapCoordinator?
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let storesSubject: PassthroughSubject<Result<[Store], Error>, Never> = PassthroughSubject()
    
    private var category: CategoryType?
    private var location: CustomLocationRequestDTO?
    private let pageSize: Int = 20
    private var currentpageSize: Int = 20
    private var lastReviewId: Int?
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let setCategory: AnyPublisher<CategoryType?, Never>
        let customLocation: AnyPublisher<CustomLocationRequestDTO, Never>
    }
    
    struct Output {
        let stores: AnyPublisher<Result<[Store], Error>, Never>
    }
    
    func transform(from input: Input) -> Output {
        input.viewDidLoad
            .sink(receiveValue: { [weak self] _ in
                self?.getStoresByBound()
            })
            .store(in: &self.cancellable)
        
        input.setCategory
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] category in
                guard let self = self else { return }
                self.category = category
                self.currentpageSize = self.pageSize
                self.lastReviewId = nil
//                self.getReviewsByBound()
                self.getStoresByBound()
            })
            .store(in: &self.cancellable)
        
        input.customLocation
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] location in
                guard let self = self else { return }
                self.location = location
                self.currentpageSize = self.pageSize
                self.lastReviewId = nil
//                self.getReviewsByBound()
                self.getStoresByBound()
            })
            .store(in: &self.cancellable)
        
        return Output(
            stores: self.storesSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - init
    
    init(
        usecase: MyPlaceUsecase,
        coordinator: MapCoordinator?
    ) {
        self.usecase = usecase
        self.coordinator = coordinator
    }
    
    // MARK: - func
    
    private func getStoresByBound() {
        Task {
            do {
                guard let location = self.location else { return }
                var stores = try await self.usecase.getStoresByBound(request: location)
                
                if let category = self.category?.rawValue {
                    stores = stores.filter { $0.category == category }
                }
                
                self.storesSubject.send(.success(stores))
            } catch(let error) {
                self.storesSubject.send(.failure(error))
            }
        }
    }
}
