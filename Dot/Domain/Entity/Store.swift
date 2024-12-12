//
//  Store.swift
//  FoodBowl
//
//  Created by Coby on 1/17/24.
//

import Foundation

// MARK: - Store
struct Store: Codable {
    let id: Int
    let originalCategory: String
    let category: String
    let name: String
    let address: String
    let phone: String
    var isBookmarked: Bool
    let distance: String
    let url: String
    let x, y: Double
    let reviewCount: String
    
    init(
        id: Int = 0,
        originalCategory: String = "",
        category: String = "",
        name: String = "",
        address: String = "",
        phone: String = "",
        isBookmarked: Bool = false,
        distance: String = "",
        url: String = "",
        x: Double = 0.0,
        y: Double = 0.0,
        reviewCount: String = ""
    ) {
        self.id = id
        self.originalCategory = originalCategory
        self.category = category
        self.name = name
        self.address = address
        self.phone = phone
        self.isBookmarked = isBookmarked
        self.distance = distance
        self.url = url
        self.x = x
        self.y = y
        self.reviewCount = reviewCount
    }
}
