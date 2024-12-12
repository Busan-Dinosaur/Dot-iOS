//
//  RecommendViewModel.swift
//  FoodBowl
//
//  Created by Coby on 2/18/24.
//

import Combine
import Foundation

final class RecommendViewModel {

    // MARK: - property
    
    private let usecase: RecommendUsecase
    private let coordinator: RecommendCoordinator?
    private var cancellable = Set<AnyCancellable>()
    
    private let size: Int = 20
    private var currentPage: Int = 0
    private var currentSize: Int = 20
    
    private let membersSubject: PassthroughSubject<Result<[Member], Error>, Never> = PassthroughSubject()
    private let moreMembersSubject: PassthroughSubject<Result<[Member], Error>, Never> = PassthroughSubject()
    private let followMemberSubject: PassthroughSubject<Result<Int, Error>, Never> = PassthroughSubject()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let scrolledToBottom: AnyPublisher<Void, Never>
        let followMember: AnyPublisher<(Int, Bool), Never>
    }
    
    struct Output {
        let members: AnyPublisher<Result<[Member], Error>, Never>
        let moreMembers: AnyPublisher<Result<[Member], Error>, Never>
        let followMember: AnyPublisher<Result<Int, Error>, Never>
    }
    
    // MARK: - init

    init(
        usecase: RecommendUsecase,
        coordinator: RecommendCoordinator
    ) {
        self.usecase = usecase
        self.coordinator = coordinator
    }
    
    // MARK: - Public - func
    
    func transform(from input: Input) -> Output {
        input.viewDidLoad
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.getMembers()
            })
            .store(in: &self.cancellable)
        
        input.scrolledToBottom
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.getMembers()
            })
            .store(in: &self.cancellable)
        
        input.followMember
            .sink(receiveValue: { [weak self] memberId, isFollow in
                guard let self = self else { return }
                isFollow ? self.unfollowMember(memberId: memberId) : self.followMember(memberId: memberId)
            })
            .store(in: &self.cancellable)
        
        return Output(
            members: self.membersSubject.eraseToAnyPublisher(),
            moreMembers: self.moreMembersSubject.eraseToAnyPublisher(),
            followMember: followMemberSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - network
    
    private func getMembers() {
        Task {
            do {
                if self.currentSize < self.size { return }
                let members = try await self.usecase.getMembersByRecommend(
                    page: self.currentPage,
                    size: self.size
                )
                self.currentPage == 0 ?
                self.membersSubject.send(.success(members)) :
                self.moreMembersSubject.send(.success(members))
                
                self.currentSize = members.count
                if self.currentSize == self.size {
                    self.currentPage += 1
                }
            } catch(let error) {
                self.currentPage == 0 ?
                self.membersSubject.send(.failure(error)) :
                self.moreMembersSubject.send(.failure(error))
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

extension RecommendViewModel: RecommendViewModelType {
    func presentMemberViewController(id: Int) {
        self.coordinator?.presentMemberViewController(id: id)
    }
}
