//
//  Place.swift
//  FoodBowl
//
//  Created by Coby Kim on 2023/01/13.
//

import Foundation
import MapKit

// MARK: - PlaceDTO
struct PlaceDTO: Codable {
    let documents: [PlaceItemDTO]
}

// MARK: - PlaceItemDTO
struct PlaceItemDTO: Codable {
    let addressName: String
    let categoryGroupCode: String
    let categoryGroupName: String
    let categoryName: String
    let id, phone, placeName: String
    let placeURL: String
    let roadAddressName, longitude, latitude: String

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case categoryGroupCode = "category_group_code"
        case categoryGroupName = "category_group_name"
        case categoryName = "category_name"
        case id, phone
        case placeName = "place_name"
        case placeURL = "place_url"
        case roadAddressName = "road_address_name"
        case longitude = "x"
        case latitude = "y"
    }
}

extension PlaceItemDTO {
    func toStore() -> Store {
        Store(
            id: Int(self.id) ?? 0,
            originalCategory: self.categoryName.components(separatedBy: ">").map { $0.trimmingCharacters(in: .whitespaces) }.first ?? "",
            category: self.getCategory(),
            name: self.placeName,
            address: self.roadAddressName != "" ? self.roadAddressName : self.addressName,
            phone: self.phone,
            isBookmarked: false,
            distance: self.getDistance(),
            url: self.placeURL,
            x: Double(self.longitude) ?? 0.0,
            y: Double(self.latitude) ?? 0.0
        )
    }
    
    func getDistance() -> String {
        guard let currentLoc = LocationManager.shared.manager.location else { return "" }
        guard let latitude = Double(self.latitude), let longitude = Double(self.longitude) else { return "" }
        let distance = currentLoc.distance(from: CLLocation(latitude:latitude, longitude: longitude))
        return String(distance).prettyDistance
    }
    
    func getCategory() -> String {
        let categoryName = self.categoryName
        let categoryArray = categoryName
            .components(separatedBy: ">").map { $0.trimmingCharacters(in: .whitespaces) }
        let categories = CategoryType.allCases.map { $0.rawValue }

        if categoryArray.count >= 2 && categories.contains(categoryArray[1]) == true {
            if categoryArray.count >= 3 && categoryArray[2] == "해물,생선" {
                return "해산물"
            }
            return categoryArray[1]
        } else if categoryArray.count >= 3 && categoryArray[2] == "제과,베이커리" {
            return "카페"
        }

        return "기타"
    }
}
