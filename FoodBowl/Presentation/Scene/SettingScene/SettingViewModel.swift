//
//  SettingViewModel.swift
//  FoodBowl
//
//  Created by Coby on 2/1/24.
//

import Combine
import Foundation

final class SettingViewModel: NSObject, BaseViewModelType {
    
    // MARK: - property
    
    private let usecase: SettingUsecase
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let isLogOutSubject: PassthroughSubject<Result<Void, Error>, Never> = PassthroughSubject()
    private let isSignOutSubject: PassthroughSubject<Result<Void, Error>, Never> = PassthroughSubject()
    
    struct Input {
        let logOut: AnyPublisher<Void, Never>
        let signOut: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let isLogOut: AnyPublisher<Result<Void, Error>, Never>
        let isSignOut: AnyPublisher<Result<Void, Error>, Never>
    }
    
    func transform(from input: Input) -> Output {
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
            isLogOut: self.isLogOutSubject.eraseToAnyPublisher(),
            isSignOut: self.isSignOutSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - init
    
    init(usecase: SettingUsecase) {
        self.usecase = usecase
    }

    // MARK: - network
    
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
