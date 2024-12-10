//
//  ReviewDetailViewModel.swift
//  FoodBowl
//
//  Created by Coby on 1/24/24.
//

import Combine
import Foundation

final class ReviewDetailViewModel {
    
    // MARK: - property
    
    private let reviewId: Int
    private var memberId: Int?
    private var storeId: Int?
    
    private let usecase: ReviewDetailUsecase
    private let coordinator: ReviewDetailCoordinator?
    private var cancellable = Set<AnyCancellable>()
    
    private let reviewSubject: PassthroughSubject<Result<Review, Error>, Never> = PassthroughSubject()
    private let isBookmarkedSubject: PassthroughSubject<Result<Void, Error>, Never> = PassthroughSubject()
    private let isRemovedSubject: PassthroughSubject<Result<Void, Error>, Never> = PassthroughSubject()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let bookmarkButtonDidTap: AnyPublisher<Bool, Never>
        let removeButtonDidTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let review: AnyPublisher<Result<Review, Error>, Never>
        let isBookmarked: AnyPublisher<Result<Void, Error>, Never>
        let isRemoved: AnyPublisher<Result<Void, Error>, Never>
    }
    
    // MARK: - init

    init(
        usecase: ReviewDetailUsecase,
        coordinator: ReviewDetailCoordinator,
        reviewId: Int
    ) {
        self.usecase = usecase
        self.coordinator = coordinator
        self.reviewId = reviewId
    }
    
    // MARK: - Public - func
    
    func transform(from input: Input) -> Output {
        input.viewDidLoad
            .sink(receiveValue: { [weak self] _ in
                self?.getReview()
            })
            .store(in: &self.cancellable)
        
        input.bookmarkButtonDidTap
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isBookmarked in
                guard let self = self else { return }
                isBookmarked ? self.removeBookmark() : self.createBookmark()
            })
            .store(in: &self.cancellable)
        
        input.removeButtonDidTap
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                self.removeReview()
            })
            .store(in: &self.cancellable)
        
        return Output(
            review: self.reviewSubject.eraseToAnyPublisher(),
            isBookmarked: self.isBookmarkedSubject.eraseToAnyPublisher(),
            isRemoved: self.isRemovedSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - network
    
    private func getReview() {
        Task {
            do {
                let deviceX = LocationManager.shared.manager.location?.coordinate.longitude ?? 0.0
                let deviceY = LocationManager.shared.manager.location?.coordinate.latitude ?? 0.0
                
                let review = try await self.usecase.getReview(request: GetReviewRequestDTO(
                    id: self.reviewId,
                    deviceX: deviceX,
                    deviceY: deviceY
                ))
                self.memberId = review.member.id
                self.storeId = review.store.id
                
                self.reviewSubject.send(.success(review))
            } catch(let error) {
                self.reviewSubject.send(.failure(error))
            }
        }
    }
    
    func createBookmark() {
        Task {
            do {
                guard let id = self.storeId else { return }
                try await self.usecase.createBookmark(storeId: id)
                self.isBookmarkedSubject.send(.success(()))
            } catch(let error) {
                self.isBookmarkedSubject.send(.failure(error))
            }
        }
    }
    
    func removeBookmark() {
        Task {
            do {
                guard let id = self.storeId else { return }
                try await self.usecase.removeBookmark(storeId: id)
                self.isBookmarkedSubject.send(.success(()))
            } catch(let error) {
                self.isBookmarkedSubject.send(.failure(error))
            }
        }
    }
    
    private func removeReview() {
        Task {
            do {
                try await self.usecase.removeReview(id: self.reviewId)
                self.isRemovedSubject.send(.success(()))
            } catch(let error) {
                self.isRemovedSubject.send(.failure(error))
            }
        }
    }
}

extension ReviewDetailViewModel: ReviewDetailViewModelType {
    
    func dismiss() {
        self.coordinator?.dismiss()
    }
    
    func presentMemberViewController() {
        guard let id = self.memberId else { return }
        self.coordinator?.presentMemberViewController(id: id)
    }
    
    func presentStoreDetailViewController() {
        guard let id = self.storeId else { return }
        self.coordinator?.presentStoreDetailViewController(id: id)
    }
    
    func presentShowWebViewController(url: String) {
        self.coordinator?.presentShowWebViewController(url: url)
    }
    
    func presentUpdateReviewViewController() {
        self.coordinator?.presentUpdateReviewViewController(reviewId:  self.reviewId)
    }
    
    func presentBlameViewController() {
        guard let id = self.storeId else { return }
        self.coordinator?.presentBlameViewController(targetId: id, blameTarget: "REVIEW")
    }
    
    func presentOptionAlert(
        onBlame: @escaping () -> Void,
        onUpdate: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        if self.memberId == UserDefaultStorage.id {
            self.presentMyReviewOptionAlert(onUpdate: onUpdate, onDelete: onDelete)
        } else {
            self.presentReviewOptionAlert(onBlame: onBlame)
        }
    }
    
    func presentReviewOptionAlert(onBlame: @escaping () -> Void) {
        self.coordinator?.presentReviewOptionAlert(onBlame: onBlame)
    }
    
    func presentMyReviewOptionAlert(
        onUpdate: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.coordinator?.presentMyReviewOptionAlert(
            onUpdate: onUpdate,
            onDelete: onDelete
        )
    }
}
