//
//  FollowingViewModel.swift
//  FoodBowl
//
//  Created by Coby on 12/21/23.
//

import Combine
import Foundation

final class FollowingViewModel: BaseViewModelType {

    // MARK: - property
    
    private let usecase: FollowUsecase
    private var cancellable = Set<AnyCancellable>()
    
    private let memberId: Int
    let isOwn: Bool
    private let size: Int = 20
    private var currentPage: Int = 0
    private var currentSize: Int = 20
    
    private let followingsSubject: PassthroughSubject<Result<[Member], Error>, Never> = PassthroughSubject()
    private let moreFollowingsSubject: PassthroughSubject<Result<[Member], Error>, Never> = PassthroughSubject()
    private let followMemberSubject: PassthroughSubject<Result<Int, Error>, Never> = PassthroughSubject()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let scrolledToBottom: AnyPublisher<Void, Never>
        let followMember: AnyPublisher<(Int, Bool), Never>
    }
    
    struct Output {
        let followings: AnyPublisher<Result<[Member], Error>, Never>
        let moreFollowings: AnyPublisher<Result<[Member], Error>, Never>
        let followMember: AnyPublisher<Result<Int, Error>, Never>
    }
    
    // MARK: - init

    init(
        usecase: FollowUsecase,
        memberId: Int,
        isOwn: Bool = false
    ) {
        self.usecase = usecase
        self.memberId = memberId
        self.isOwn = isOwn
    }
    
    // MARK: - Public - func
    
    func transform(from input: Input) -> Output {
        input.viewDidLoad
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.getFollowings()
            })
            .store(in: &self.cancellable)
        
        input.scrolledToBottom
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.getFollowings()
            })
            .store(in: &self.cancellable)
        
        input.followMember
            .sink(receiveValue: { [weak self] memberId, isFollow in
                guard let self = self else { return }
                isFollow ? self.unfollowMember(memberId: memberId) : self.followMember(memberId: memberId)
            })
            .store(in: &self.cancellable)
        
        return Output(
            followings: self.followingsSubject.eraseToAnyPublisher(),
            moreFollowings: self.moreFollowingsSubject.eraseToAnyPublisher(),
            followMember: followMemberSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - network
    
    private func getFollowings() {
        Task {
            do {
                if self.currentSize < self.size { return }
                let members = try await self.usecase.getFollowingMember(
                    memberId: self.memberId,
                    page: self.currentPage,
                    size: self.size
                )
                self.currentPage = members.currentPage
                self.currentSize = members.currentSize
                
                self.currentPage == 0 ?
                self.followingsSubject.send(.success(members.content)) :
                self.moreFollowingsSubject.send(.success(members.content))
            } catch(let error) {
                self.currentPage == 0 ?
                self.followingsSubject.send(.failure(error)) :
                self.moreFollowingsSubject.send(.failure(error))
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
