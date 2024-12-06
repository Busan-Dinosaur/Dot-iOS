//
//  ReviewDetailViewModel.swift
//  FoodBowl
//
//  Created by Coby on 1/24/24.
//

import Combine
import Foundation

final class ReviewDetailViewModel: BaseViewModelType {
    
    // MARK: - property
    
    let reviewId: Int
    var memberId: Int = 0
    var storeId: Int = 0
    
    private let usecase: ReviewDetailUsecase
    private var cancellable = Set<AnyCancellable>()
    
    private let reviewSubject: PassthroughSubject<Result<Review, Error>, Never> = PassthroughSubject()
    private let isBookmarkedSubject: PassthroughSubject<Result<Void, Error>, Never> = PassthroughSubject()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let bookmarkButtonDidTap: AnyPublisher<Bool, Never>
    }
    
    struct Output {
        let review: AnyPublisher<Result<Review, Error>, Never>
        let isBookmarked: AnyPublisher<Result<Void, Error>, Never>
    }
    
    // MARK: - init

    init(
        usecase: ReviewDetailUsecase,
        reviewId: Int
    ) {
        self.usecase = usecase
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
        
        return Output(
            review: self.reviewSubject.eraseToAnyPublisher(),
            isBookmarked: self.isBookmarkedSubject.eraseToAnyPublisher()
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
