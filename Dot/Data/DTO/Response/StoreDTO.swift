//
//  StoreDTO.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/12/23.
//

import Foundation

// MARK: - StoreDTO
struct StoreDTO: Codable {
    let stores: [StoreItemDTO]
}

// MARK: - StoreItemDTO
struct StoreItemDTO: Codable {
    let id: Int
    let name, categoryName, addressName, url: String
    let x, y: Double
    let reviewCount: Int
    let isBookmarked: Bool
    
    func toStore() -> Store {
        Store(
            id: self.id,
            category: self.categoryName,
            name: self.name,
            address: self.addressName,
            isBookmarked: self.isBookmarked,
            distance: "",
            url: self.url,
            x: self.x,
            y: self.y,
            reviewCount: self.reviewCount.prettyNumber
        )
    }
}

// MARK: - StoreBySearchDTO
struct StoreBySearchDTO: Codable {
    let searchResponses: [StoreItemBySearchDTO]
}

// MARK: - StoreItemBySearchDTO
struct StoreItemBySearchDTO: Codable {
    let storeId: Int
    let storeName: String
    let address: String
    let category: String
    let distance: Double
    let reviewCount: Int
    
    func toStore() -> Store {
        Store(
            id: self.storeId,
            category: self.category,
            name: self.storeName,
            address: self.address,
            isBookmarked: false,
            distance: self.distance.prettyDistance,
            url: "",
            x: 0.0,
            y: 0.0,
            reviewCount: self.reviewCount.prettyNumber
        )
    }
}
