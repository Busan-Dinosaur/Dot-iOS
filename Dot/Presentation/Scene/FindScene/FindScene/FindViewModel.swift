//
//  FindViewModel.swift
//  FoodBowl
//
//  Created by Coby on 1/19/24.
//

import Combine
import Foundation

final class FindViewModel {
    
    // MARK: - property
    
    private let usecase: FindUsecase
    private let coordinator: FindCoordinator?
    private var cancellable = Set<AnyCancellable>()
    
    private let pageSize: Int = 20
    private var currentpageSize: Int = 20
    private var lastReviewId: Int?
    
    private let size: Int = 20
    
    private let reviewsSubject: PassthroughSubject<Result<[Review], Error>, Never> = PassthroughSubject()
    private let moreReviewsSubject: PassthroughSubject<Result<[Review], Error>, Never> = PassthroughSubject()
    private let refreshControlSubject: PassthroughSubject<Void, Error> = PassthroughSubject()
    private let storesAndMembersSubject: PassthroughSubject<Result<([Store], [Member]), Error>, Never> = PassthroughSubject()
    private let followMemberSubject: PassthroughSubject<Result<Int, Error>, Never> = PassthroughSubject()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let scrolledToBottom: AnyPublisher<Void, Never>
        let refreshControl: AnyPublisher<Void, Never>
        let searchStoresAndMembers: AnyPublisher<String, Never>
        let followMember: AnyPublisher<(Int, Bool), Never>
    }
    
    struct Output {
        let reviews: AnyPublisher<Result<[Review], Error>, Never>
        let moreReviews: AnyPublisher<Result<[Review], Error>, Never>
        let storesAndMembers: AnyPublisher<Result<([Store], [Member]), Error>, Never>
        let followMember: AnyPublisher<Result<Int, Error>, Never>
    }
    
    // MARK: - init

    init(
        usecase: FindUsecase,
        coordinator: FindCoordinator
    ) {
        self.usecase = usecase
        self.coordinator = coordinator
    }
    
    // MARK: - Public - func
    
    func transform(from input: Input) -> Output {
        input.viewDidLoad
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.getReviews()
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
        
        input.searchStoresAndMembers
            .removeDuplicates()
            .sink(receiveValue: { [weak self] keyword in
                self?.searchStoresAndMembers(keyword: keyword)
            })
            .store(in: &self.cancellable)
        
        input.followMember
            .sink(receiveValue: { [weak self] memberId, isFollow in
                isFollow ? self?.unfollowMember(memberId: memberId) : self?.followMember(memberId: memberId)
            })
            .store(in: &self.cancellable)
        
        return Output(
            reviews: reviewsSubject.eraseToAnyPublisher(),
            moreReviews: moreReviewsSubject.eraseToAnyPublisher(),
            storesAndMembers: storesAndMembersSubject.eraseToAnyPublisher(),
            followMember: followMemberSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - network
    
    private func getReviews(lastReviewId: Int? = nil) {
        Task {
            do {
                if currentpageSize < pageSize { return }
                let deviceX = LocationManager.shared.manager.location?.coordinate.longitude ?? 0.0
                let deviceY = LocationManager.shared.manager.location?.coordinate.latitude ?? 0.0
                
                let review = try await self.usecase.getReviewsByFeed(request: GetReviewsByFeedRequestDTO(
                    lastReviewId: lastReviewId,
                    pageSize: self.pageSize,
                    deviceX: deviceX,
                    deviceY: deviceY
                ))
                
                self.lastReviewId = review.page.lastId
                self.currentpageSize = review.page.size
                
                lastReviewId == nil ? self.reviewsSubject.send(.success(review.reviews)) : self.moreReviewsSubject.send(.success(review.reviews))
            } catch(let error) {
                self.reviewsSubject.send(.failure(error))
            }
        }
    }
    
    private func searchStoresAndMembers(keyword: String) {
        Task {
            do {
                guard let location = LocationManager.shared.manager.location?.coordinate else { return }
                let deviceX = location.longitude
                let deviceY = location.latitude
                
                let (stores, members) = try await Task {
                    async let stores = self.usecase.getStoresBySearch(request: SearchStoreRequestDTO(
                        name: keyword,
                        x: deviceX,
                        y: deviceY,
                        size: self.size
                    ))
                    async let members = self.usecase.getMembersBySearch(request: SearchMemberRequestDTO(
                        name: keyword,
                        size: self.size
                    ))

                    return await (try stores, try members)
                }.value
                
                self.storesAndMembersSubject.send(.success((stores, members)))
            } catch(let error) {
                self.storesAndMembersSubject.send(.failure(error))
            }
        }
    }
    
    private func followMember(memberId: Int) {
        Task {
            do {
                try await self.usecase.followMember(memberId: memberId)
                self.followMemberSubject.send(.success(memberId))
            } catch(let error) {
                self.followMemberSubject.send(.failure(error))
            }
        }
    }
    
    private func unfollowMember(memberId: Int) {
        Task {
            do {
                try await self.usecase.unfollowMember(memberId: memberId)
                self.followMemberSubject.send(.success(memberId))
            } catch(let error) {
                self.followMemberSubject.send(.failure(error))
            }
        }
    }
}

extension FindViewModel: FindViewModelType {
    
    func presentRecommendViewController() {
        self.coordinator?.presentRecommendViewController()
    }
    
    func presentMemberViewController(id: Int) {
        self.coordinator?.presentMemberViewController(id: id)
    }
    
    func presentStoreDetailViewController(id: Int) {
        self.coordinator?.presentStoreDetailViewController(id: id)
    }
    
    func presentReviewDetailViewController(id: Int) {
        self.coordinator?.presentReviewDetailViewController(id: id)
    }
}
