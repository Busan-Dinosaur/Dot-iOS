//
//  MoyaProvider+Extension.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/08/10.
//

import Foundation

import Moya

extension MoyaProvider {
    func request(_ target: Target) async -> Result<Response, MoyaError> {
        await withCheckedContinuation { continuation in
            self.request(target) { result in
                continuation.resume(returning: result)
            }
        }
    }
}

extension MoyaProvider where Target == ServiceAPI {
    func request(_ target: Target) async -> Result<Response, MoyaError> {
        // 토큰 갱신이 필요한지 체크
        if !isTokenValid() {
            // 토큰 갱신이 필요한 경우
            let refreshTokenResult = await refreshToken()
            if case .failure = refreshTokenResult {
                // 토큰 갱신 실패 시, 실패 결과 반환
                return .failure(MoyaError.requestMapping("토큰 갱신 실패"))
            }
        }
        
        // 토큰 갱신 후 또는 갱신이 필요 없는 경우, 원래 요청 수행
        return await withCheckedContinuation { continuation in
            self.request(target) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    private func isTokenValid() -> Bool {
        guard let expiryDate = UserDefaults.standard.object(forKey: "tokenExpiryDate") as? Date else {
            return false
        }
        return Date() < expiryDate
    }
    
    private func refreshToken() async -> Result<Void, MoyaError> {
        let accessToken: String = KeychainManager.get(.accessToken)
        let refreshToken: String = KeychainManager.get(.refreshToken)
        
        let provider = MoyaProvider<SignAPI>()
        let result = await provider.request(.patchRefreshToken(token: Token(
            accessToken: accessToken,
            refreshToken: refreshToken
        )))
        switch result {
        case .success(let response):
            do {
                let token = try JSONDecoder().decode(Token.self, from: response.data)
                
                KeychainManager.set(token.accessToken, for: .accessToken)
                KeychainManager.set(token.refreshToken, for: .refreshToken)
                
                let expiryDate = Date().addingTimeInterval(1800)
                UserDefaultHandler.setTokenExpiryDate(tokenExpiryDate: expiryDate)
                
                return .success(())
            } catch {
                return .failure(MoyaError.jsonMapping(response))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
