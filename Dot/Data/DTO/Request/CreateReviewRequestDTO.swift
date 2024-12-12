//
//  CreateReviewRequestDTO.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/09/10.
//

import Foundation

struct CreateReviewRequestDTO: Encodable {
    let locationId: String
    let storeName: String
    let storeAddress: String
    let x: Double
    let y: Double
    let storeUrl: String
    let phone: String
    let category: String
    let reviewContent: String
    let schoolName: String?
    let schoolAddress: String?
    let schoolX: Double?
    let schoolY: Double?
    
    init(
        locationId: String,
        storeName: String,
        storeAddress: String,
        x: Double,
        y: Double, 
        storeUrl: String,
        phone: String, 
        category: String, 
        reviewContent: String,
        schoolName: String? = nil,
        schoolAddress: String? = nil,
        schoolX: Double? = nil,
        schoolY: Double? = nil
    ) {
        self.locationId = locationId
        self.storeName = storeName
        self.storeAddress = storeAddress
        self.x = x
        self.y = y
        self.storeUrl = storeUrl
        self.phone = phone
        self.category = category
        self.reviewContent = reviewContent
        self.schoolName = schoolName
        self.schoolAddress = schoolAddress
        self.schoolX = schoolX
        self.schoolY = schoolY
    }
}
