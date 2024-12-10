//
//  SearchStoreViewModel.swift
//  FoodBowl
//
//  Created by Coby on 1/18/24.
//

import Combine
import UIKit
import MapKit

final class SearchStoreViewModel: NSObject, BaseViewModelType {
    
    // MARK: - property
    
    private var location: CLLocationCoordinate2D? = nil
    
    private let usecase: CreateReviewUsecase
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let storesSubject: PassthroughSubject<Result<[Store], Error>, Never> = PassthroughSubject()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let searchStores: AnyPublisher<String, Never>
    }
    
    struct Output {
        let stores: AnyPublisher<Result<[Store], Error>, Never>
    }
    
    func transform(from input: Input) -> Output {
        input.viewDidLoad
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                if let location = self.location {
                    self.searchStoresByLocation(location: location)
                }
            })
            .store(in: &self.cancellable)
        
        input.searchStores
            .removeDuplicates()
            .sink(receiveValue: { [weak self] keyword in
                self?.searchStores(keyword: keyword)
            })
            .store(in: &self.cancellable)
        
        return Output(
            stores: self.storesSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - init
    
    init(
        usecase: CreateReviewUsecase,
        location: CLLocationCoordinate2D?
    ) {
        self.usecase = usecase
        self.location = location
    }
    
    // MARK: - network
    
    private func searchStoresByLocation(location: CLLocationCoordinate2D) {
        Task {
            do {
                let deviceX = String(location.longitude)
                let deviceY = String(location.latitude)
                let stores = try await self.usecase.searchStoresByLocation(x: deviceX, y: deviceY)
                self.storesSubject.send(.success(stores))
            } catch(let error) {
                self.storesSubject.send(.failure(error))
            }
        }
    }
    
    private func searchStores(keyword: String) {
        Task {
            do {
                guard let location = LocationManager.shared.manager.location?.coordinate else { return }
                let deviceX = String(location.longitude)
                let deviceY = String(location.latitude)
                let stores = try await self.usecase.searchStores(x: deviceX, y: deviceY, keyword: keyword)
                self.storesSubject.send(.success(stores))
            } catch(let error) {
                self.storesSubject.send(.failure(error))
            }
        }
    }
}
