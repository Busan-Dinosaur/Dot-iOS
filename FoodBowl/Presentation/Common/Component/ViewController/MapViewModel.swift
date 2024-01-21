//
//  MapViewModel.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/12/23.
//

import Combine
import UIKit

import CombineMoya
import Moya

final class MapViewModel: BaseViewModelType {
    
    typealias Task = _Concurrency.Task
    
    // MARK: - property

    private let provider = MoyaProvider<ServiceAPI>()
    private var cancellable = Set<AnyCancellable>()
    
    private let pageSize: Int = 20
    private let size: Int = 20
    private var currentpageSize: Int = 20
    private var lastReviewId: Int?

    var customLocation: CustomLocationRequestDTO?
    var type: MapViewType = .friend
    var isBookmark: Bool = false
    var schoolId: Int?
    var memberId: Int?
    
    private let reviewsSubject = PassthroughSubject<[ReviewItemDTO], Error>()
    private let moreReviewsSubject = PassthroughSubject<[ReviewItemDTO], Error>()
    private let storesSubject = PassthroughSubject<[StoreItemDTO], Error>()
    private let refreshControlSubject = PassthroughSubject<Void, Never>()
    
    struct Input {
        let customLocation: AnyPublisher<CustomLocationRequestDTO, Never>
        let scrolledToBottom: AnyPublisher<Void, Never>
        let refreshControl: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let reviews: PassthroughSubject<[ReviewItemDTO], Error>
        let moreReviews: PassthroughSubject<[ReviewItemDTO], Error>
        let stores: PassthroughSubject<[StoreItemDTO], Error>
        let refreshControl: PassthroughSubject<Void, Never>
    }
    
    // MARK: - Public - func
    
    func transform(from input: Input) -> Output {
        input.customLocation
            .sink(receiveValue: { [weak self] customLocation in
                guard let self = self else { return }
                self.customLocation = customLocation
                self.currentpageSize = self.pageSize
                self.lastReviewId = nil
                
                switch self.type {
                case .friend:
                    self.isBookmark ? self.getReviewsByBookmark() : self.getReviewsByFollowing()
                    self.isBookmark ? self.getStoresByBookmark() : self.getStoresByFollowing()
                case .univ:
                    self.getReviewsBySchool()
                    self.getStoresBySchool()
                case .member:
                    self.getReviewsByMember()
                    self.getStoresByMember()
                }
                
                self.renewToken()
            })
            .store(in: &self.cancellable)
        
        input.scrolledToBottom
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                
                switch self.type {
                case .friend:
                    self.isBookmark ? self.getReviewsByBookmark(lastReviewId: self.lastReviewId) : self.getReviewsByFollowing(lastReviewId: self.lastReviewId)
                case .univ:
                    self.getReviewsBySchool(lastReviewId: self.lastReviewId)
                case .member:
                    self.getReviewsByMember(lastReviewId: self.lastReviewId)
                }
            })
            .store(in: &self.cancellable)
        
        input.refreshControl
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.currentpageSize = self.pageSize
                self.lastReviewId = nil                
                
                switch self.type {
                case .friend:
                    self.isBookmark ? self.getReviewsByBookmark() : self.getReviewsByFollowing()
                case .univ:
                    self.getReviewsBySchool()
                case .member:
                    self.getReviewsByMember()
                }
            })
            .store(in: &self.cancellable)
        
        return Output(
            reviews: reviewsSubject,
            moreReviews: moreReviewsSubject,
            stores: storesSubject,
            refreshControl: refreshControlSubject
        )
    }
}

// MARK: - Review Method
extension MapViewModel {
    private func getReviewsByFollowing(lastReviewId: Int? = nil) {
        Task {
            if currentpageSize < pageSize { return }
            guard let customLocation = customLocation else { return }
            
            let response = await self.provider.request(
                .getReviewsByFollowing(request: GetReviewsRequestDTO(
                    location: customLocation,
                    lastReviewId: lastReviewId,
                    pageSize: self.pageSize
                )
            ))
            switch response {
            case .success(let result):
                guard let data = try? result.map(ReviewDTO.self) else { return }
                self.lastReviewId = data.page.lastId
                self.currentpageSize = data.page.size
                
                lastReviewId == nil ? self.reviewsSubject.send(data.reviews) : self.moreReviewsSubject.send(data.reviews)
            case .failure(let err):
                handleError(err)
            }
            self.refreshControlSubject.send()
        }
    }
    
    private func getReviewsByBookmark(lastReviewId: Int? = nil) {
        Task {
            if currentpageSize < pageSize { return }
            guard let customLocation = customLocation else { return }
            
            let response = await self.provider.request(
                .getReviewsByBookmark(request: GetReviewsRequestDTO(
                    location: customLocation,
                    lastReviewId: lastReviewId,
                    pageSize: self.pageSize
                )
            ))
            
            switch response {
            case .success(let result):
                guard let data = try? result.map(ReviewDTO.self) else { return }
                self.lastReviewId = data.page.lastId
                self.currentpageSize = data.page.size
                
                lastReviewId == nil ? self.reviewsSubject.send(data.reviews) : self.moreReviewsSubject.send(data.reviews)
            case .failure(let err):
                handleError(err)
            }
            self.refreshControlSubject.send()
        }
    }
    
    private func getReviewsBySchool(lastReviewId: Int? = nil) {
        Task {
            if currentpageSize < pageSize { return }
            guard let customLocation = customLocation, let schoolId = schoolId else { return }
            
            let response = await self.provider.request(
                .getReviewsBySchool(request: GetReviewsBySchoolRequestDTO(
                    location: customLocation,
                    lastReviewId: lastReviewId,
                    pageSize: self.pageSize,
                    schoolId: schoolId
                )
            ))
            
            switch response {
            case .success(let result):
                guard let data = try? result.map(ReviewDTO.self) else { return }
                self.lastReviewId = data.page.lastId
                self.currentpageSize = data.page.size
                
                lastReviewId == nil ? self.reviewsSubject.send(data.reviews) : self.moreReviewsSubject.send(data.reviews)
            case .failure(let err):
                handleError(err)
            }
            self.refreshControlSubject.send()
        }
    }
    
    private func getReviewsByMember(lastReviewId: Int? = nil) {
        Task {
            if currentpageSize < pageSize { return }
            guard let customLocation = customLocation, let memberId = memberId else { return }
            
            let response = await self.provider.request(
                .getReviewsByMember(request: GetReviewsByMemberRequestDTO(
                    location: customLocation,
                    lastReviewId: lastReviewId,
                    pageSize: self.pageSize,
                    memberId: memberId
                )
            ))
            
            switch response {
            case .success(let result):
                guard let data = try? result.map(ReviewDTO.self) else { return }
                self.lastReviewId = data.page.lastId
                self.currentpageSize = data.page.size
                
                lastReviewId == nil ? self.reviewsSubject.send(data.reviews) : self.moreReviewsSubject.send(data.reviews)
            case .failure(let err):
                handleError(err)
            }
            self.refreshControlSubject.send()
        }
    }
    
    func removeReview(id: Int) async -> Bool {
        let response = await provider.request(.removeReview(id: id))
        switch response {
        case .success:
            return true
        case .failure(let err):
            handleError(err)
            return false
        }
    }
}

// MARK: - Store Method
extension MapViewModel {
    func getStoresByFollowing() {
        Task {
            guard let customLocation = customLocation else { return }
            
            let response = await provider.request(.getStoresByFollowing(request: customLocation))
            switch response {
            case .success(let result):
                guard let data = try? result.map(StoreDTO.self) else { return }
                self.storesSubject.send(data.stores)
            case .failure(let err):
                handleError(err)
            }
        }
    }
    
    func getStoresByBookmark() {
        Task {
            guard let customLocation = customLocation else { return }
            
            let response = await provider.request(.getStoresByBookmark(request: customLocation))
            switch response {
            case .success(let result):
                guard let data = try? result.map(StoreDTO.self) else { return }
                self.storesSubject.send(data.stores)
            case .failure(let err):
                handleError(err)
            }
        }
    }
    
    func getStoresBySchool() {
        Task {
            guard let customLocation = customLocation, let schoolId = schoolId else { return }
            
            let response = await provider.request(.getStoresBySchool(
                request: GetStoresBySchoolRequestDTO(
                    location: customLocation,
                    schoolId: schoolId
                )
            ))
                
            switch response {
            case .success(let result):
                guard let data = try? result.map(StoreDTO.self) else { return }
                self.storesSubject.send(data.stores)
            case .failure(let err):
                handleError(err)
            }
        }
    }
    
    func getStoresByMember() {
        Task {
            guard let customLocation = customLocation, let memberId = memberId else { return }
            
            let response = await provider.request(.getStoresByMember(
                request: GetStoresByMemberRequestDTO(
                    location: customLocation,
                    memberId: memberId
                )
            ))
            
            switch response {
            case .success(let result):
                guard let data = try? result.map(StoreDTO.self) else { return }
                self.storesSubject.send(data.stores)
            case .failure(let err):
                handleError(err)
            }
        }
    }

    func createBookmark(storeId: Int) async -> Bool {
        let response = await provider.request(.createBookmark(storeId: storeId))
        switch response {
        case .success:
            return true
        case .failure(let err):
            handleError(err)
            return false
        }
    }

    func removeBookmark(storeId: Int) async -> Bool {
        let response = await provider.request(.removeBookmark(storeId: storeId))
        switch response {
        case .success:
            return true
        case .failure(let err):
            handleError(err)
            return false
        }
    }
}

// MARK: - Follow Method
extension MapViewModel {
    func followMember(memberId: Int) async -> Bool {
        let response = await provider.request(.followMember(memberId: memberId))
        switch response {
        case .success:
            return true
        case .failure(let err):
            handleError(err)
            return false
        }
    }

    func unfollowMember(memberId: Int) async -> Bool {
        let response = await provider.request(.unfollowMember(memberId: memberId))
        switch response {
        case .success:
            return false
        case .failure(let err):
            handleError(err)
            return true
        }
    }

    func getFollowerMembers(memberId: Int, page: Int = 0) async -> [MemberByFollowItemDTO] {
        let response = await provider.request(
            .getFollowerMember(
                memberId: memberId,
                page: page,
                size: size
            )
        )
        switch response {
        case .success(let result):
            guard let data = try? result.map(MemberByFollowDTO.self) else { return [] }
            return data.content
        case .failure(let err):
            handleError(err)
            return []
        }
    }

    func getFollowingMembers(memberId: Int, page: Int = 0) async -> [MemberByFollowItemDTO] {
        let response = await provider.request(
            .getFollowingMember(
                memberId: memberId,
                page: page,
                size: size
            )
        )
        switch response {
        case .success(let result):
            guard let data = try? result.map(MemberByFollowDTO.self) else { return [] }
            return data.content
        case .failure(let err):
            handleError(err)
            return []
        }
    }

    func removeFollowingMember(memberId: Int) async -> Bool {
        let response = await provider.request(.removeFollower(memberId: memberId))
        switch response {
        case .success:
            return true
        case .failure(let err):
            handleError(err)
            return false
        }
    }
}

// MARK: - Get and Update Profile
extension MapViewModel {
    func getMemberProfile(id: Int) async -> MemberProfileDTO? {
        let response = await provider.request(.getMemberProfile(id: id))
        switch response {
        case .success(let result):
            guard let data = try? result.map(MemberProfileDTO.self) else { return nil }
            return data
        case .failure(let err):
            handleError(err)
            return nil
        }
    }

    func updateMembeProfile(profile: UpdateMemberProfileRequestDTO) async {
        let response = await provider.request(.updateMemberProfile(request: profile))
        switch response {
        case .success:
            UserDefaultHandler.setNickname(nickname: profile.nickname)
            UserDefaultHandler.setIntroduction(introduction: profile.introduction)
        case .failure(let err):
            handleError(err)
        }
    }

    func updateMembeProfileImage(image: UIImage) async {
        guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        let response = await provider.request(.updateMemberProfileImage(image: imageData))
        switch response {
        case .success(let result):
            guard let data = try? result.map(UpdateProfileImageDTO.self) else { return }
            UserDefaultHandler.setProfileImageUrl(profileImageUrl: data.profileImageUrl)
        case .failure(let err):
            handleError(err)
        }
    }
}

// MARK: - Get Stores and Members
extension MapViewModel {
    func serachStores(name: String) async -> [StoreItemBySearchDTO] {
        guard let customLocation = LocationManager.shared.manager.location?.coordinate else { return [] }
        
        let response = await provider.request(.getStoresBySearch(
            request: SearchStoreRequestDTO(
                name: name,
                x: customLocation.longitude,
                y: customLocation.latitude,
                size: size
            )
        ))
        
        switch response {
        case .success(let result):
            guard let data = try? result.map(StoreBySearchDTO.self) else { return [] }
            return data.searchResponses
        case .failure(let err):
            handleError(err)
            return []
        }
    }

    func searchMembers(name: String) async -> [MemberDTO] {
        let response = await provider.request(
            .getMembersBySearch(
                request: SearchMemberRequestDTO(
                    name: name,
                    size: size
                )
            )
        )
        switch response {
        case .success(let result):
            guard let data = try? result.map(MemberBySearchDTO.self) else { return [] }
            return data.memberSearchResponses
        case .failure(let err):
            handleError(err)
            return []
        }
    }
}

// MARK: - ETC
extension MapViewModel {
    func getSchools() async -> [SchoolItemDTO] {
        let response = await provider.request(.getSchools)
        switch response {
        case .success(let result):
            guard let data = try? result.map(SchoolDTO.self) else { return [SchoolItemDTO]() }
            return data.schools
        case .failure(let err):
            handleError(err)
            return [SchoolItemDTO]()
        }
    }
    
    func renewToken() {
        let tokenDTO = TokenDTO(
            accessToken: KeychainManager.get(.accessToken),
            refreshToken: KeychainManager.get(.refreshToken)
        )
        
        provider.request(.patchRefreshToken(token: tokenDTO)) { response in
            switch response {
            case .success(let result):
                guard let data = try? result.map(TokenDTO.self) else { return }
                KeychainManager.set(data.accessToken, for: .accessToken)
                KeychainManager.set(data.refreshToken, for: .refreshToken)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}