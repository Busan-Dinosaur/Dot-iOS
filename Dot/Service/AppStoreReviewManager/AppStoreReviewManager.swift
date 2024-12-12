//
//  AppStoreReviewManager.swift
//  FoodBowl
//
//  Created by Coby on 2/7/24.
//

import UIKit
import StoreKit

class AppStoreReviewManager {
    
    static var isReviewable: Bool { UserDefaultStorage.inAppReviewCount == 3 }
    
    static func requestReviewIfAppropriate() {
        guard UserDefaultStorage.inAppReviewCount <= 3 else { return }
        UserDefaultHandler.setInAppReviewCount(inAppReviewCount: UserDefaultStorage.inAppReviewCount + 1)
        
        guard isReviewable else { return }
        let scene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive }
        if let scene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
