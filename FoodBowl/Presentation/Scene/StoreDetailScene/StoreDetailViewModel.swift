//
//  StoreDetailViewModel.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/16/23.
//

import Combine
import Foundation

final class StoreDetailViewModel: BaseViewModelType {
    
    // MARK: - property
    
    private let usecase: StoreDetailUsecase
    private var cancellable = Set<AnyCancellable>()
    
    private let storeId: Int
    var isFriend: Bool
    private let pageSize: Int = 20
    private var currentpageSize: Int = 20
    private var lastReviewId: Int?
    
    private let storeSubject: PassthroughSubject<Result<Store, Error>, Never> = PassthroughSubject()
    private let reviewsSubject: PassthroughSubject<Result<[Review], Error>, Never> = PassthroughSubject()
    private let moreReviewsSubject: PassthroughSubject<Result<[Review], Error>, Never> = PassthroughSubject()
    private let refreshControlSubject: PassthroughSubject<Void, Error> = PassthroughSubject()
    private let isBookmarkedSubject: PassthroughSubject<Result<Void, Error>, Never> = PassthroughSubject()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let reviewToggleButtonDidTap: AnyPublisher<Bool, Never>
        let bookmarkButtonDidTap: AnyPublisher<Bool, Never>
        let scrolledToBottom: AnyPublisher<Void, Never>
        let refreshControl: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let store: AnyPublisher<Result<Store, Error>, Never>
        let reviews: AnyPublisher<Result<[Review], Error>, Never>
        let moreReviews: AnyPublisher<Result<[Review], Error>, Never>
        let isBookmarked: AnyPublisher<Result<Void, Error>, Never>
    }
    
    // MARK: - init

    init(
        usecase: StoreDetailUsecase,
        storeId: Int,
        isFriend: Bool = true
    ) {
        self.usecase = usecase
        self.storeId = storeId
        self.isFriend = isFriend
    }
    
    // MARK: - Public - func
    
    func transform(from input: Input) -> Output {
        input.viewDidLoad
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.getReviews()
            })
            .store(in: &self.cancellable)
        
        input.reviewToggleButtonDidTap
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isFriend in
                guard let self = self else { return }
                self.currentpageSize = self.pageSize
                self.lastReviewId = nil
                self.isFriend = isFriend
                self.getReviews()
            })
            .store(in: &self.cancellable)
        
        input.bookmarkButtonDidTap
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isBookmark in
                guard let self = self else { return }
                isBookmark ? self.removeBookmark() : self.createBookmark()
            })
            .store(in: &self.cancellable)
        
        input.scrolledToBottom
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.getReviews(lastReviewId: self.lastReviewId)
            })
            .store(in: &self.cancellable)
        
        input.refreshControl
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.currentpageSize = self.pageSize
                self.lastReviewId = nil
                self.getReviews()
            })
            .store(in: &self.cancellable)
        
        return Output(
            store: self.storeSubject.eraseToAnyPublisher(),
            reviews: self.reviewsSubject.eraseToAnyPublisher(),
            moreReviews: self.moreReviewsSubject.eraseToAnyPublisher(),
            isBookmarked: self.isBookmarkedSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - network
    
    private func getReviews(lastReviewId: Int? = nil) {
        Task {
            do {
                if currentpageSize < pageSize { return }
                let filter = self.isFriend ? "FRIEND" : "ALL"
                let deviceX = LocationManager.shared.manager.location?.coordinate.longitude ?? 0.0
                let deviceY = LocationManager.shared.manager.location?.coordinate.latitude ?? 0.0
                
                let reviews = try await self.usecase.getReviewsByStore(request: GetReviewsByStoreRequestDTO(
                    lastReviewId: lastReviewId,
                    pageSize: self.pageSize,
                    storeId: self.storeId,
                    filter: filter,
                    deviceX: deviceX,
                    deviceY: deviceY
                ))
                
                let store = reviews.store
                self.storeSubject.send(.success(store))
                
                self.lastReviewId = reviews.page.lastId
                self.currentpageSize = reviews.page.size
                
                lastReviewId == nil ? self.reviewsSubject.send(.success(reviews.reviews)) : self.moreReviewsSubject.send(.success(reviews.reviews))
            } catch(let error) {
                self.reviewsSubject.send(.failure(error))
            }
        }
    }
    
    func createBookmark() {
        Task {
            do {
                try await self.usecase.createBookmark(storeId: self.storeId)
                self.isBookmarkedSubject.send(.success(()))
            } catch(let error) {
                self.isBookmarkedSubject.send(.failure(error))
            }
        }
    }
    
    func removeBookmark() {
        Task {
            do {
                try await self.usecase.removeBookmark(storeId: self.storeId)
                self.isBookmarkedSubject.send(.success(()))
            } catch(let error) {
                self.isBookmarkedSubject.send(.failure(error))
            }
        }
    }
}
