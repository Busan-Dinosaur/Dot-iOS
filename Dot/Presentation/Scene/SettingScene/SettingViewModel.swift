//
//  SettingViewModel.swift
//  FoodBowl
//
//  Created by Coby on 2/1/24.
//

import Combine
import Foundation

final class SettingViewModel: NSObject {
    
    // MARK: - property
    
    private let usecase: SettingUsecase
    private let coordinator: SettingCoordinator?
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let memberSubject: PassthroughSubject<Result<Member, Error>, Never> = PassthroughSubject()
    private let isLogOutSubject: PassthroughSubject<Result<Void, Error>, Never> = PassthroughSubject()
    private let isSignOutSubject: PassthroughSubject<Result<Void, Error>, Never> = PassthroughSubject()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let viewWillAppear: AnyPublisher<Void, Never>
        let logOut: AnyPublisher<Void, Never>
        let signOut: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let member: AnyPublisher<Result<Member, Error>, Never>
        let isLogOut: AnyPublisher<Result<Void, Error>, Never>
        let isSignOut: AnyPublisher<Result<Void, Error>, Never>
    }
    
    func transform(from input: Input) -> Output {
        input.viewDidLoad
            .sink(receiveValue: { [weak self] _ in
                self?.getMyProfile()
            })
            .store(in: &self.cancellable)
        
        input.viewWillAppear
            .sink(receiveValue: { [weak self] _ in
                self?.getMyProfile()
            })
            .store(in: &self.cancellable)
        
        input.logOut
            .sink(receiveValue: { [weak self] in
                self?.logOut()
            })
            .store(in: &self.cancellable)
        
        input.signOut
            .sink(receiveValue: { [weak self] in
                self?.signOut()
            })
            .store(in: &self.cancellable)
        
        return Output(
            member: self.memberSubject.eraseToAnyPublisher(),
            isLogOut: self.isLogOutSubject.eraseToAnyPublisher(),
            isSignOut: self.isSignOutSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - init
    
    init(
        usecase: SettingUsecase,
        coordinator: SettingCoordinator
    ) {
        self.usecase = usecase
        self.coordinator = coordinator
    }

    // MARK: - network
    
    private func getMyProfile() {
        Task {
            do {
                let member = try await self.usecase.getMyProfile()
                self.memberSubject.send(.success(member))
            } catch(let error) {
                self.memberSubject.send(.failure(error))
            }
        }
    }
    
    private func logOut() {
        Task {
            do {
                try await self.usecase.logOut()
                KeychainManager.clear()
                UserDefaultHandler.clearAllData()
                self.isLogOutSubject.send(.success(()))
            } catch(let error) {
                self.isLogOutSubject.send(.failure(error))
            }
        }
    }
    
    private func signOut() {
        Task {
            do {
                try await self.usecase.signOut()
                KeychainManager.clear()
                UserDefaultHandler.clearAllData()
                self.isLogOutSubject.send(.success(()))
            } catch(let error) {
                self.isLogOutSubject.send(.failure(error))
            }
        }
    }
}

extension SettingViewModel: SettingViewModelType {
    
    func presentFollowerViewController() {
        self.coordinator?.presentFollowerViewController(id: UserDefaultStorage.id)
    }
    
    func presentFollowingViewController() {
        self.coordinator?.presentFollowingViewController(id: UserDefaultStorage.id)
    }
    
    func presentUpdateProfileViewController() {
        self.coordinator?.presentUpdateProfileViewController()
    }
    
    func presentShowWebViewController(url: String) {
        self.coordinator?.presentShowWebViewController(url: url)
    }
}
