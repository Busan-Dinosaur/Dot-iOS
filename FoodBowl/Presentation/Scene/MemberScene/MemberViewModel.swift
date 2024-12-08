//
//  MemberViewModel.swift
//  FoodBowl
//
//  Created by Coby on 12/8/24.
//

import Combine
import Foundation

final class MemberViewModel: NSObject {
    
    // MARK: - property
    
    private let usecase: MemberUsecase
    private let coordinator: MemberCoordinator?
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let memberSubject: PassthroughSubject<Result<Member, Error>, Never> = PassthroughSubject()
    private let followMemberSubject: PassthroughSubject<Result<Int, Error>, Never> = PassthroughSubject()
    private let storesSubject: PassthroughSubject<Result<[Store], Error>, Never> = PassthroughSubject()
    private let reviewsSubject: PassthroughSubject<Result<[Review], Error>, Never> = PassthroughSubject()
    private let moreReviewsSubject: PassthroughSubject<Result<[Review], Error>, Never> = PassthroughSubject()
    private let refreshControlSubject: PassthroughSubject<Void, Error> = PassthroughSubject()
    private let isBookmarkedSubject: PassthroughSubject<Result<Int, Error>, Never> = PassthroughSubject()
    
    private let memberId: Int
    private var category: CategoryType?
    private var switchType: SwitchType = .all
    private var location: CustomLocationRequestDTO?
    private let pageSize: Int = 20
    private var currentpageSize: Int = 20
    private var lastReviewId: Int?
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let setCategory: AnyPublisher<CategoryType?, Never>
        let followMember: AnyPublisher<(Int, Bool), Never>
        let customLocation: AnyPublisher<CustomLocationRequestDTO, Never>
        let bookmarkButtonDidTap: AnyPublisher<(Int, Bool), Never>
        let scrolledToBottom: AnyPublisher<Void, Never>
        let refreshControl: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let member: AnyPublisher<Result<Member, Error>, Never>
        let followMember: AnyPublisher<Result<Int, Error>, Never>
        let stores: AnyPublisher<Result<[Store], Error>, Never>
        let reviews: AnyPublisher<Result<[Review], Error>, Never>
        let moreReviews: AnyPublisher<Result<[Review], Error>, Never>
        let isBookmarked: AnyPublisher<Result<Int, Error>, Never>
    }
    
    func transform(from input: Input) -> Output {
        input.viewDidLoad
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
//                self.getMemberProfile(memberId: self.memberId)
            })
            .store(in: &self.cancellable)
        
        input.setCategory
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] category in
                guard let self = self else { return }
                self.category = category
                self.currentpageSize = self.pageSize
                self.lastReviewId = nil
                self.getReviewsByMember()
                self.getStoresByMember()
            })
            .store(in: &self.cancellable)
        
        input.followMember
            .sink(receiveValue: { [weak self] memberId, isFollow in
                guard let self = self else { return }
                isFollow ? self.unfollowMember(memberId: memberId) : self.followMember(memberId: memberId)
            })
            .store(in: &self.cancellable)
        
        input.customLocation
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] location in
                guard let self = self else { return }
                self.location = location
                self.currentpageSize = self.pageSize
                self.lastReviewId = nil
                self.getReviewsByMember()
                self.getStoresByMember()
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
                self.getReviewsByMember(lastReviewId: self.lastReviewId)
            })
            .store(in: &self.cancellable)
        
        input.refreshControl
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.currentpageSize = self.pageSize
                self.lastReviewId = nil
                self.getReviewsByMember()
            })
            .store(in: &self.cancellable)
        
        return Output(
            member: self.memberSubject.eraseToAnyPublisher(),
            followMember: self.followMemberSubject.eraseToAnyPublisher(),
            stores: self.storesSubject.eraseToAnyPublisher(),
            reviews: self.reviewsSubject.eraseToAnyPublisher(),
            moreReviews: self.moreReviewsSubject.eraseToAnyPublisher(),
            isBookmarked: self.isBookmarkedSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - init
    
    init(
        usecase: MemberUsecase,
        coordinator: MemberCoordinator?,
        memberId: Int
    ) {
        self.usecase = usecase
        self.coordinator = coordinator
        self.memberId = memberId
    }
    
    // MARK: - func
    
    private func getMemberProfile(memberId: Int) {
        Task {
            do {
                let member = try await self.usecase.getMemberProfile(id: memberId)
                self.memberSubject.send(.success(member))
            } catch(let error) {
                self.memberSubject.send(.failure(error))
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
                    memberId: self.memberId
                ))
                
                self.lastReviewId = reviews.page.lastId
                self.currentpageSize = reviews.page.size
                
                lastReviewId == nil ? self.reviewsSubject.send(.success(reviews.reviews)) : self.moreReviewsSubject.send(.success(reviews.reviews))
            } catch(let error) {
                self.reviewsSubject.send(.failure(error))
            }
        }
    }
    
    private func getStoresByMember() {
        Task {
            do {
                guard let location = self.location else { return }
                var stores = try await self.usecase.getStoresByMember(request: GetStoresByMemberRequestDTO(
                    location: location,
                    memberId: self.memberId
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

extension MemberViewModel: MemberViewModelType {
    
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
