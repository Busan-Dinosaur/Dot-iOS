//
//  MapViewModel.swift
//  FoodBowl
//
//  Created by Coby on 12/3/24.
//

import Combine
import Foundation

final class MapViewModel: NSObject {
    
    // MARK: - property
    
    private let usecase: MapUsecase
    private let coordinator: MapCoordinator?
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let storesSubject: PassthroughSubject<Result<[Store], Error>, Never> = PassthroughSubject()
    private let reviewsSubject: PassthroughSubject<Result<[Review], Error>, Never> = PassthroughSubject()
    private let moreReviewsSubject: PassthroughSubject<Result<[Review], Error>, Never> = PassthroughSubject()
    private let refreshControlSubject: PassthroughSubject<Void, Error> = PassthroughSubject()
    private let isBookmarkedSubject: PassthroughSubject<Result<Int, Error>, Never> = PassthroughSubject()
    
    private var category: CategoryType?
    private var switchType: SwitchType = .all
    private var location: CustomLocationRequestDTO?
    private let pageSize: Int = 20
    private var currentpageSize: Int = 20
    private var lastReviewId: Int?
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let setCategory: AnyPublisher<CategoryType?, Never>
        let customLocation: AnyPublisher<CustomLocationRequestDTO, Never>
        let switchButtonDidTap: AnyPublisher<SwitchType, Never>
        let bookmarkButtonDidTap: AnyPublisher<(Int, Bool), Never>
        let scrolledToBottom: AnyPublisher<Void, Never>
        let refreshControl: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let stores: AnyPublisher<Result<[Store], Error>, Never>
        let reviews: AnyPublisher<Result<[Review], Error>, Never>
        let moreReviews: AnyPublisher<Result<[Review], Error>, Never>
        let isBookmarked: AnyPublisher<Result<Int, Error>, Never>
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
                self.getBySwitchType()
            })
            .store(in: &self.cancellable)
        
        input.customLocation
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] location in
                guard let self = self else { return }
                self.location = location
                self.getBySwitchType()
            })
            .store(in: &self.cancellable)
        
        input.switchButtonDidTap
            .removeDuplicates()
            .sink(receiveValue: { [weak self] switchType in
                guard let self = self else { return }
                self.switchType = switchType
                self.getBySwitchType()
            })
            .store(in: &self.cancellable)
        
        input.bookmarkButtonDidTap
            .sink(receiveValue: { [weak self] storeId, isBookmark in
                guard let self = self else { return }
                isBookmark ? self.removeBookmark(storeId: storeId) : self.createBookmark(storeId: storeId)
            })
            .store(in: &self.cancellable)
        
        input.scrolledToBottom
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.getMoreReviewsBySwitchType(lastReviewId: self.lastReviewId)
            })
            .store(in: &self.cancellable)
        
        input.refreshControl
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.getBySwitchType()
            })
            .store(in: &self.cancellable)
        
        return Output(
            stores: self.storesSubject.eraseToAnyPublisher(),
            reviews: self.reviewsSubject.eraseToAnyPublisher(),
            moreReviews: self.moreReviewsSubject.eraseToAnyPublisher(),
            isBookmarked: self.isBookmarkedSubject.eraseToAnyPublisher()
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
    
    private func getBySwitchType() {
        self.currentpageSize = self.pageSize
        self.lastReviewId = nil
        
        switch self.switchType {
        case .all:
            self.getReviewsByBound()
            self.getStoresByBound()
        case .friends:
            self.getReviewsByFollowing()
            self.getStoresByFollowing()
        case .person:
            self.getReviewsByMember()
            self.getStoresByMember()
        case .bookmark:
            self.getReviewsByBookmark()
            self.getStoresByBookmark()
        }
    }
    
    private func getMoreReviewsBySwitchType(lastReviewId: Int? = nil) {
        switch self.switchType {
        case .all:
            self.getReviewsByBound(lastReviewId: lastReviewId)
        case .friends:
            self.getReviewsByFollowing(lastReviewId: lastReviewId)
        case .person:
            self.getReviewsByMember(lastReviewId: lastReviewId)
        case .bookmark:
            self.getReviewsByBookmark(lastReviewId: lastReviewId)
        }
    }
    
    private func getReviewsByBound(lastReviewId: Int? = nil) {
        Task {
            do {
                guard let location = self.location else { return }
                if self.currentpageSize < self.pageSize { return }
                
                let reviews = try await self.usecase.getReviewsByBound(request: GetReviewsRequestDTO(
                    location: location,
                    lastReviewId: lastReviewId,
                    pageSize: self.pageSize,
                    category: self.category?.rawValue
                ))
                
                self.lastReviewId = reviews.page.lastId
                self.currentpageSize = reviews.page.size
                
                lastReviewId == nil ? self.reviewsSubject.send(.success(reviews.reviews)) : self.moreReviewsSubject.send(.success(reviews.reviews))
            } catch(let error) {
                self.reviewsSubject.send(.failure(error))
            }
        }
    }
    
    private func getReviewsByFollowing(lastReviewId: Int? = nil) {
        Task {
            do {
                guard let location = self.location else { return }
                if self.currentpageSize < self.pageSize { return }
                
                let reviews = try await self.usecase.getReviewsByFollowing(request: GetReviewsRequestDTO(
                    location: location,
                    lastReviewId: lastReviewId,
                    pageSize: self.pageSize,
                    category: self.category?.rawValue
                ))
                
                self.lastReviewId = reviews.page.lastId
                self.currentpageSize = reviews.page.size
                
                lastReviewId == nil ? self.reviewsSubject.send(.success(reviews.reviews)) : self.moreReviewsSubject.send(.success(reviews.reviews))
            } catch(let error) {
                self.reviewsSubject.send(.failure(error))
            }
        }
    }
    
    private func getReviewsByBookmark(lastReviewId: Int? = nil) {
        Task {
            do {
                guard let location = self.location else { return }
                if self.currentpageSize < self.pageSize { return }
                
                let reviews = try await self.usecase.getReviewsByFollowing(request: GetReviewsRequestDTO(
                    location: location,
                    lastReviewId: lastReviewId,
                    pageSize: self.pageSize,
                    category: self.category?.rawValue
                ))
                
                self.lastReviewId = reviews.page.lastId
                self.currentpageSize = reviews.page.size
                
                lastReviewId == nil ? self.reviewsSubject.send(.success(reviews.reviews)) : self.moreReviewsSubject.send(.success(reviews.reviews))
            } catch(let error) {
                self.reviewsSubject.send(.failure(error))
            }
        }
    }
    
    private func getReviewsByMember(lastReviewId: Int? = nil) {
        Task {
            do {
                guard let location = self.location else { return }
                if self.currentpageSize < self.pageSize { return }
                
                let reviews = try await self.usecase.getReviewsByMember(request: GetReviewsByMemberRequestDTO(
                    location: location,
                    lastReviewId: lastReviewId,
                    pageSize: self.pageSize,
                    category: self.category?.rawValue,
                    memberId: UserDefaultStorage.id
                ))
                
                self.lastReviewId = reviews.page.lastId
                self.currentpageSize = reviews.page.size
                
                lastReviewId == nil ? self.reviewsSubject.send(.success(reviews.reviews)) : self.moreReviewsSubject.send(.success(reviews.reviews))
            } catch(let error) {
                self.reviewsSubject.send(.failure(error))
            }
        }
    }
    
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
    
    private func getStoresByFollowing() {
        Task {
            do {
                guard let location = self.location else { return }
                var stores = try await self.usecase.getStoresByFollowing(request: location)
                
                if let category = self.category?.rawValue {
                    stores = stores.filter { $0.category == category }
                }
                
                self.storesSubject.send(.success(stores))
            } catch(let error) {
                self.storesSubject.send(.failure(error))
            }
        }
    }
    
    private func getStoresByBookmark() {
        Task {
            do {
                guard let location = self.location else { return }
                var stores = try await self.usecase.getStoresByBookmark(request: location)
                
                if let category = self.category?.rawValue {
                    stores = stores.filter { $0.category == category }
                }
                
                self.storesSubject.send(.success(stores))
            } catch(let error) {
                self.storesSubject.send(.failure(error))
            }
        }
    }
    
    private func getStoresByMember() {
        Task {
            do {
                guard let location = self.location else { return }
                var stores = try await self.usecase.getStoresByMember(request: GetStoresByMemberRequestDTO(
                    location: location,
                    memberId: UserDefaultStorage.id
                ))
                
                if let category = self.category?.rawValue {
                    stores = stores.filter { $0.category == category }
                }
                
                self.storesSubject.send(.success(stores))
            } catch(let error) {
                self.storesSubject.send(.failure(error))
            }
        }
    }
    
    private func createBookmark(storeId: Int) {
        Task {
            do {
                try await self.usecase.createBookmark(storeId: storeId)
                self.isBookmarkedSubject.send(.success(storeId))
            } catch(let error) {
                self.isBookmarkedSubject.send(.failure(error))
            }
        }
    }
    
    private func removeBookmark(storeId: Int) {
        Task {
            do {
                try await self.usecase.removeBookmark(storeId: storeId)
                self.isBookmarkedSubject.send(.success(storeId))
            } catch(let error) {
                self.isBookmarkedSubject.send(.failure(error))
            }
        }
    }
}

extension MapViewModel: MapViewModelType {
    
    func presentFindViewController() {
        self.coordinator?.presentFindViewController()
    }
    
    func presentPhotoesSelectViewController() {
        self.coordinator?.presentPhotoesSelectViewController()
    }
    
    func presentSettingViewController() {
        self.coordinator?.presentSettingViewController()
    }
    
    func presentRecommendViewController() {
        self.coordinator?.presentRecommendViewController()
    }
    
    func presentProfileViewController(id: Int) {
        self.coordinator?.presentProfileViewController(id: id)
    }
    
    func presentStoreDetailViewController(id: Int) {
        self.coordinator?.presentStoreDetailViewController(id: id)
    }
    
    func presentReviewDetailViewController(id: Int) {
        self.coordinator?.presentReviewDetailViewController(id: id)
    }
}
