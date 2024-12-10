//
//  StoreDetailViewModel.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/16/23.
//

import Combine
import Foundation

final class StoreDetailViewModel {
    
    // MARK: - property
    
    private let usecase: StoreDetailUsecase
    private let coordinator: StoreDetailCoordinator?
    private var cancellable = Set<AnyCancellable>()
    
    private let storeId: Int
    private let pageSize: Int = 20
    private var currentpageSize: Int = 20
    private var lastReviewId: Int?
    
    private let storeSubject: PassthroughSubject<Result<Store, Error>, Never> = PassthroughSubject()
    private let reviewsSubject: PassthroughSubject<Result<[Review], Error>, Never> = PassthroughSubject()
    private let moreReviewsSubject: PassthroughSubject<Result<[Review], Error>, Never> = PassthroughSubject()
    private let refreshControlSubject: PassthroughSubject<Void, Error> = PassthroughSubject()
    private let isBookmarkedSubject: PassthroughSubject<Result<Void, Error>, Never> = PassthroughSubject()
    private let isRemovedSubject: PassthroughSubject<Result<Int, Error>, Never> = PassthroughSubject()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let bookmarkButtonDidTap: AnyPublisher<Bool, Never>
        let removeButtonDidTap: AnyPublisher<Int, Never>
        let scrolledToBottom: AnyPublisher<Void, Never>
        let refreshControl: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let store: AnyPublisher<Result<Store, Error>, Never>
        let reviews: AnyPublisher<Result<[Review], Error>, Never>
        let moreReviews: AnyPublisher<Result<[Review], Error>, Never>
        let isBookmarked: AnyPublisher<Result<Void, Error>, Never>
        let isRemoved: AnyPublisher<Result<Int, Error>, Never>
    }
    
    // MARK: - init

    init(
        usecase: StoreDetailUsecase,
        coordinator: StoreDetailCoordinator,
        storeId: Int
    ) {
        self.usecase = usecase
        self.coordinator = coordinator
        self.storeId = storeId
    }
    
    // MARK: - Public - func
    
    func transform(from input: Input) -> Output {
        input.viewDidLoad
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
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
        
        input.removeButtonDidTap
            .sink(receiveValue: { [weak self] reviewId in
                guard let self = self else { return }
                self.removeReview(id: reviewId)
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
            isBookmarked: self.isBookmarkedSubject.eraseToAnyPublisher(),
            isRemoved: self.isRemovedSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - network
    
    private func getReviews(lastReviewId: Int? = nil) {
        Task {
            do {
                if self.currentpageSize < self.pageSize { return }
                guard let deviceX = LocationManager.shared.manager.location?.coordinate.longitude,
                      let deviceY = LocationManager.shared.manager.location?.coordinate.latitude
                else {
                    return
                }
                
                let reviews = try await self.usecase.getReviewsByStore(request: GetReviewsByStoreRequestDTO(
                    lastReviewId: lastReviewId,
                    pageSize: self.pageSize,
                    storeId: self.storeId,
                    filter: "ALL",
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
    
    private func createBookmark() {
        Task {
            do {
                try await self.usecase.createBookmark(storeId: self.storeId)
                self.isBookmarkedSubject.send(.success(()))
            } catch(let error) {
                self.isBookmarkedSubject.send(.failure(error))
            }
        }
    }
    
    private func removeBookmark() {
        Task {
            do {
                try await self.usecase.removeBookmark(storeId: self.storeId)
                self.isBookmarkedSubject.send(.success(()))
            } catch(let error) {
                self.isBookmarkedSubject.send(.failure(error))
            }
        }
    }
    
    private func removeReview(id: Int) {
        Task {
            do {
                try await self.usecase.removeReview(id: id)
                self.isRemovedSubject.send(.success(id))
            } catch(let error) {
                self.isRemovedSubject.send(.failure(error))
            }
        }
    }
}

extension StoreDetailViewModel: StoreDetailViewModelType {
    
    func dismiss() {
        self.coordinator?.dismiss()
    }
    
    func presentMemberViewController(id: Int) {
        self.coordinator?.presentMemberViewController(id: id)
    }
    
    func presentStoreDetailViewController() {
        self.coordinator?.presentStoreDetailViewController(id: self.storeId)
    }
    
    func presentReviewDetailViewController(id: Int) {
        self.coordinator?.presentReviewDetailViewController(id: id)
    }
    
    func presentShowWebViewController(url: String) {
        self.coordinator?.presentShowWebViewController(url: url)
    }
    
    func presentUpdateReviewViewController(reviewId: Int) {
        self.coordinator?.presentUpdateReviewViewController(reviewId: reviewId)
    }
    
    func presentBlameViewController(targetId: Int, blameTarget: String) {
        self.coordinator?.presentBlameViewController(targetId: targetId, blameTarget: blameTarget)
    }
    
    func presentReviewOptionAlert(onBlame: @escaping () -> Void) {
        self.coordinator?.presentReviewOptionAlert(onBlame: onBlame)
    }
    
    func presentMyReviewOptionAlert(onUpdate: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.coordinator?.presentMyReviewOptionAlert(onUpdate: onUpdate, onDelete: onDelete)
    }
}
