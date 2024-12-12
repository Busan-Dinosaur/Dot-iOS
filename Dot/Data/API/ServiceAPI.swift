//
//  ServiceAPI.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/12/23.
//

import Foundation

import Moya

enum ServiceAPI {
    case checkNickname(nickname: String)
    case getSchools
    case getCategories
    
    case createBlame(request: CreateBlameRequestDTO)
    
    case createReview(request: CreateReviewRequestDTO, images: [Data])
    case updateReview(id: Int, request: UpdateReviewRequestDTO, images: [Data])
    case removeReview(id: Int)
    case getReview(request: GetReviewRequestDTO)
    case getReviewsByFollowing(request: GetReviewsRequestDTO)
    case getReviewsByBookmark(request: GetReviewsRequestDTO)
    case getReviewsByStore(request: GetReviewsByStoreRequestDTO)
    case getReviewsByBound(request: GetReviewsRequestDTO)
    case getReviewsByMember(request: GetReviewsByMemberRequestDTO)
    case getReviewsByFeed(request: GetReviewsByFeedRequestDTO)
    
    case getStoresBySearch(request: SearchStoreRequestDTO)
    case getStoresByBound(request: CustomLocationRequestDTO)
    case getStoresByMember(request: GetStoresByMemberRequestDTO)
    case getStoresByFollowing(request: CustomLocationRequestDTO)
    case getStoresByBookmark(request: CustomLocationRequestDTO)
    
    case createBookmark(storeId: Int)
    case removeBookmark(storeId: Int)
    
    case updateMemberProfile(request: UpdateMemberProfileRequestDTO)
    case removeMemberProfileImage
    case updateMemberProfileImage(image: Data)
    case getMemberProfile(id: Int)
    case getMembersBySearch(request: SearchMemberRequestDTO)
    case followMember(memberId: Int)
    case unfollowMember(memberId: Int)
    case removeFollower(memberId: Int)
    case getFollowingMember(memberId: Int, page: Int, size: Int)
    case getFollowerMember(memberId: Int, page: Int, size: Int)
    case getRecommendMember(page: Int, size: Int)
}

extension ServiceAPI: TargetType {
    var baseURL: URL {
        @Configurations(key: ConfigurationsKey.baseURL, defaultValue: "")
        var baseURL: String
        return URL(string: baseURL)!
    }

    var path: String {
        switch self {
        case .checkNickname:
            return "/v1/members/nickname/exist"
        case .getSchools:
            return "/v1/schools"
        case .getCategories:
            return "/v1/stores/categories"
        case .createBlame:
            return "/v1/blames"
        case .createReview:
            return "/v1/reviews"
        case .updateReview(let id, _, _):
            return "/v1/reviews/\(id)"
        case .removeReview(let id):
            return "/v1/reviews/\(id)"
        case .getReview(let request):
            return "/v1/reviews/\(request.id)"
        case .getReviewsByStore:
            return "/v1/reviews/stores"
        case .getReviewsByBound:
            return "/v1/reviews/bounds"
        case .getReviewsByMember:
            return "/v1/reviews/members"
        case .getReviewsByFollowing:
            return "/v1/reviews/following"
        case .getReviewsByBookmark:
            return "/v1/reviews/bookmarks"
        case .getReviewsByFeed:
            return "/v1/reviews/feeds"
        case .getStoresBySearch:
            return "/v1/stores/search"
        case .getStoresByBound:
            return "/v1/stores/bounds"
        case .getStoresByMember:
            return "/v1/stores/members"
        case .getStoresByFollowing:
            return "/v1/stores/followings"
        case .getStoresByBookmark:
            return "/v1/stores/bookmarks"
        case .createBookmark, .removeBookmark:
            return "/v1/bookmarks"
        case .updateMemberProfile:
            return "/v1/members/profile"
        case .removeMemberProfileImage, .updateMemberProfileImage:
            return "/v1/members/profile/image"
        case .getMemberProfile(let id):
            return "/v1/members/\(id)/profile"
        case .getMembersBySearch:
            return "/v1/members/search"
        case .followMember(let memberId):
            return "/v1/follows/\(memberId)/follow"
        case .unfollowMember(let memberId):
            return "/v1/follows/\(memberId)/unfollow"
        case .removeFollower(let memberId):
            return "/v1/follows/followers/\(memberId)"
        case .getFollowingMember(let memberId, _, _):
            return "/v1/follows/\(memberId)/followings"
        case .getFollowerMember(let memberId, _, _):
            return "/v1/follows/\(memberId)/followers"
        case .getRecommendMember:
            return "/v1/members/by-reviews"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createBlame, .createReview, .createBookmark, .followMember:
            return .post
        case .updateMemberProfile, .updateMemberProfileImage, .updateReview:
            return .patch
        case .removeReview, .removeBookmark, .removeMemberProfileImage, .unfollowMember, .removeFollower:
            return .delete
        default:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .checkNickname(let nickname):
            let params: [String: String] = [
                "nickname": nickname
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .createBlame(let request):
            return .requestJSONEncodable(request)
        case .createReview(let request, let images):
            var multipartFormData = [MultipartFormData]()

            if let reviewData = try? JSONEncoder().encode(request) {
                multipartFormData.append(
                    MultipartFormData(
                        provider: .data(reviewData),
                        name: "request",
                        mimeType: "application/json"
                    )
                )
            }
            
            for image in images {
                multipartFormData.append(
                    MultipartFormData(
                        provider: .data(image),
                        name: "images",
                        fileName: "\(UUID().uuidString).jpg",
                        mimeType: "image/jpeg"
                    )
                )
            }
            
            return .uploadMultipart(multipartFormData)
        case .updateReview(_, let request, let images):
            var multipartFormData = [MultipartFormData]()

            if let reviewData = try? JSONEncoder().encode(request) {
                multipartFormData.append(
                    MultipartFormData(
                        provider: .data(reviewData),
                        name: "request",
                        mimeType: "application/json"
                    )
                )
            }
            
            for image in images {
                multipartFormData.append(
                    MultipartFormData(
                        provider: .data(image),
                        name: "images",
                        fileName: "\(UUID().uuidString).jpg",
                        mimeType: "image/jpeg"
                    )
                )
            }
            
            return .uploadMultipart(multipartFormData)
        case .removeReview:
            return .requestPlain
        case .getReview(let request):
            let params: [String: Any] = [
                "id": request.id,
                "deviceX": request.deviceX,
                "deviceY": request.deviceY
            ]

            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getReviewsByStore(let request):
            var params: [String: Any] = [
                "storeId": request.storeId,
                "filter": request.filter,
                "pageSize": request.pageSize,
                "deviceX": request.deviceX,
                "deviceY": request.deviceY
            ]

            if let lastReviewId = request.lastReviewId {
                params["lastReviewId"] = lastReviewId
            }

            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getReviewsByBound(let request):
            var params: [String: Any] = [
                "x": request.location.x,
                "y": request.location.y,
                "deltaX": request.location.deltaX,
                "deltaY": request.location.deltaY,
                "deviceX": request.location.deviceX,
                "deviceY": request.location.deviceY,
                "pageSize": request.pageSize
            ]
            
            if let category = request.category {
                params["category"] = category
            }

            if let lastReviewId = request.lastReviewId {
                params["lastReviewId"] = lastReviewId
            }

            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getReviewsByMember(let request):
            var params: [String: Any] = [
                "memberId": request.memberId,
                "x": request.location.x,
                "y": request.location.y,
                "deltaX": request.location.deltaX,
                "deltaY": request.location.deltaY,
                "deviceX": request.location.deviceX,
                "deviceY": request.location.deviceY,
                "pageSize": request.pageSize
            ]
            
            if let category = request.category {
                params["category"] = category
            }

            if let lastReviewId = request.lastReviewId {
                params["lastReviewId"] = lastReviewId
            }

            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getReviewsByFollowing(let request):
            var params: [String: Any] = [
                "x": request.location.x,
                "y": request.location.y,
                "deltaX": request.location.deltaX,
                "deltaY": request.location.deltaY,
                "deviceX": request.location.deviceX,
                "deviceY": request.location.deviceY,
                "pageSize": request.pageSize
            ]
            
            if let category = request.category {
                params["category"] = category
            }

            if let lastReviewId = request.lastReviewId {
                params["lastReviewId"] = lastReviewId
            }

            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getReviewsByBookmark(let request):
            var params: [String: Any] = [
                "x": request.location.x,
                "y": request.location.y,
                "deltaX": request.location.deltaX,
                "deltaY": request.location.deltaY,
                "deviceX": request.location.deviceX,
                "deviceY": request.location.deviceY,
                "pageSize": request.pageSize
            ]
            
            if let category = request.category {
                params["category"] = category
            }

            if let lastReviewId = request.lastReviewId {
                params["lastReviewId"] = lastReviewId
            }

            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getReviewsByFeed(let request):
            var params: [String: Any] = [
                "deviceX": request.deviceX,
                "deviceY": request.deviceY,
                "pageSize": request.pageSize
            ]

            if let lastReviewId = request.lastReviewId {
                params["lastReviewId"] = lastReviewId
            }

            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getStoresBySearch(let request):
            let params: [String: Any] = [
                "name": request.name,
                "x": request.x,
                "y": request.y,
                "size": request.size
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getStoresByBound(let request):
            let params: [String: Any] = [
                "x": request.x,
                "y": request.y,
                "deltaX": request.deltaX,
                "deltaY": request.deltaY
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getStoresByMember(let request):
            let params: [String: Any] = [
                "x": request.location.x,
                "y": request.location.y,
                "deltaX": request.location.deltaX,
                "deltaY": request.location.deltaY,
                "memberId": request.memberId
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getStoresByFollowing(let request):
            let params: [String: Any] = [
                "x": request.x,
                "y": request.y,
                "deltaX": request.deltaX,
                "deltaY": request.deltaY
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getStoresByBookmark(let request):
            let params: [String: Any] = [
                "x": request.x,
                "y": request.y,
                "deltaX": request.deltaX,
                "deltaY": request.deltaY
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .createBookmark(let storeId):
            let params: [String: Int] = [
                "storeId": storeId
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding(destination: .queryString)
            )
        case .removeBookmark(let storeId):
            let params: [String: Int] = [
                "storeId": storeId
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .updateMemberProfile(let request):
            return .requestJSONEncodable(request)
        case .updateMemberProfileImage(let image):
            let id = String(describing: UserDefaultStorage.id)
            let imageData = MultipartFormData(
                provider: .data(image),
                name: "image",
                fileName: "\(id).jpg",
                mimeType: "image/jpeg"
            )
            return .uploadMultipart([imageData])
        case .getMembersBySearch(let form):
            let params: [String: Any] = [
                "name": form.name,
                "size": form.size
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getFollowingMember(_, let page, let size):
            let params: [String: Int] = [
                "page": page,
                "size": size
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getFollowerMember(_, let page, let size):
            let params: [String: Int] = [
                "page": page,
                "size": size
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        case .getRecommendMember(let page, let size):
            let params: [String: Int] = [
                "page": page,
                "size": size
            ]
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.default
            )
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        let accessToken: String = KeychainManager.get(.accessToken)
        
        switch self {
        case .createReview, .updateReview:
            return [
                "Content-Type": "application/json",
                "Content-type": "multipart/form-data",
                "Authorization": "Bearer " + accessToken
            ]
        default:
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer " + accessToken
            ]
        }
    }

    var validationType: ValidationType { .successCodes }
}
