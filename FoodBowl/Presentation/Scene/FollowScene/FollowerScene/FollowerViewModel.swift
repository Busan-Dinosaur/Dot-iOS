//
//  FollowerViewModel.swift
//  FoodBowl
//
//  Created by Coby on 12/21/23.
//

import Combine
import Foundation

final class FollowerViewModel: BaseViewModelType {

    // MARK: - property
    
    private let usecase: FollowUsecase
    private var cancellable = Set<AnyCancellable>()
    
    private let memberId: Int
    let isOwn: Bool
    private let size: Int = 20
    private var currentPage: Int = 0
    private var currentSize: Int = 20
    
    private let followersSubject: PassthroughSubject<Result<[Member], Error>, Never> = PassthroughSubject()
    private let moreFollowersSubject: PassthroughSubject<Result<[Member], Error>, Never> = PassthroughSubject()
    private let followMemberSubject: PassthroughSubject<Result<Int, Error>, Never> = PassthroughSubject()
    private let removeMemberSubject: PassthroughSubject<Result<Int, Error>, Never> = PassthroughSubject()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let scrolledToBottom: AnyPublisher<Void, Never>
        let followMember: AnyPublisher<(Int, Bool), Never>
    }
    
    struct Output {
        let followers: AnyPublisher<Result<[Member], Error>, Never>
        let moreFollowers: AnyPublisher<Result<[Member], Error>, Never>
        let followMember: AnyPublisher<Result<Int, Error>, Never>
        let removeMember: AnyPublisher<Result<Int, Error>, Never>
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
                self.getFollowers()
            })
            .store(in: &self.cancellable)
        
        input.scrolledToBottom
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.getFollowers()
            })
            .store(in: &self.cancellable)
        
        input.followMember
            .sink(receiveValue: { [weak self] memberId, isFollow in
                guard let self = self else { return }
                if self.isOwn {
                    self.removeMember(memberId: memberId)
                } else {
                    isFollow ? self.unfollowMember(memberId: memberId) : self.followMember(memberId: memberId)
                }
            })
            .store(in: &self.cancellable)
        
        return Output(
            followers: self.followersSubject.eraseToAnyPublisher(),
            moreFollowers: self.moreFollowersSubject.eraseToAnyPublisher(),
            followMember: followMemberSubject.eraseToAnyPublisher(),
            removeMember: removeMemberSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - network
    
    private func getFollowers() {
        Task {
            do {
                if self.currentSize < self.size { return }
                let members = try await self.usecase.getFollowerMember(
                    memberId: self.memberId,
                    page: self.currentPage,
                    size: self.size
                )
                self.currentPage = members.currentPage
                self.currentSize = members.currentSize
                
                self.currentPage == 0 ? 
                self.followersSubject.send(.success(members.content)) :
                self.moreFollowersSubject.send(.success(members.content))
            } catch(let error) {
                self.currentPage == 0 ?
                self.followersSubject.send(.failure(error)) :
                self.moreFollowersSubject.send(.failure(error))
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
    
    private func removeMember(memberId: Int) {
        Task {
            do {
                try await self.usecase.removeFollower(memberId: memberId)
                self.removeMemberSubject.send(.success(memberId))
            } catch(let error) {
                self.removeMemberSubject.send(.failure(error))
            }
        }
    }
}
