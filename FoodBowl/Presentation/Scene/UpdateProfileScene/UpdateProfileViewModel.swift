//
//  UpdateProfileViewModel.swift
//  FoodBowl
//
//  Created by Coby on 1/21/24.
//

import Combine
import UIKit

import Kingfisher

final class UpdateProfileViewModel: NSObject, BaseViewModelType {
    
    // MARK: - property
    
    private var isEnabled: Bool = true
    
    private var profileImage: UIImage = ImageLiteral.defaultProfile
    
    private let usecase: UpdateProfileUsecase
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let profileSubject: PassthroughSubject<Result<Member, Error>, Never> = PassthroughSubject()
    private let isCompletedSubject: PassthroughSubject<Result<Void, Error>, Never> = PassthroughSubject()
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let setProfileImage: AnyPublisher<UIImage, Never>
        let completeButtonDidTap: AnyPublisher<(String, String), Never>
    }
    
    struct Output {
        let profile: AnyPublisher<Result<Member, Error>, Never>
        let isCompleted: AnyPublisher<Result<Void, Error>, Never>
    }
    
    func transform(from input: Input) -> Output {
        input.viewDidLoad
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.getMyProfile()
            })
            .store(in: &self.cancellable)
        
        input.setProfileImage
            .sink(receiveValue: { [weak self] image in
                self?.profileImage = image
            })
            .store(in: &self.cancellable)
        
        input.completeButtonDidTap
            .sink(receiveValue: { [weak self] nickname, introduction in
                guard let self = self else { return }
                if self.isEnabled {
                    self.isEnabled = false
                    self.updateMemberProfile(nickname: nickname, introduction: introduction)
                }
            })
            .store(in: &self.cancellable)
        
        return Output(
            profile: self.profileSubject.eraseToAnyPublisher(),
            isCompleted: self.isCompletedSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - init
    
    init(usecase: UpdateProfileUsecase) {
        self.usecase = usecase
    }
    
    // MARK: - network
    
    private func getMyProfile() {
        Task {
            do {
                let profile = try await self.usecase.getMyProfile()
                
                if let profileImageUrl = profile.profileImageUrl,
                   let url = URL(string: profileImageUrl) {
                    KingfisherManager.shared.retrieveImage(with: url) { result in
                        switch result {
                        case .success(let value):
                            self.profileImage = value.image
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                
                self.profileSubject.send(.success(profile))
            } catch(let error) {
                self.profileSubject.send(.failure(error))
            }
        }
    }
    
    private func updateMemberProfile(nickname: String, introduction: String) {
        Task {
            let imageData = self.profileImage.jpegData(compressionQuality: 0.3)!
            async let profileUpdate: () = self.usecase.updateMemberProfile(request: UpdateMemberProfileRequestDTO(
                nickname: nickname,
                introduction: introduction
            ))
            async let imageUpdate: () = self.usecase.updateMemberProfileImage(image: imageData)
            
            do {
                try await profileUpdate
                try await imageUpdate
                self.isCompletedSubject.send(.success(()))
            } catch(let error) {
                self.isEnabled = true
                self.isCompletedSubject.send(.failure(error))
            }
        }
    }
}
