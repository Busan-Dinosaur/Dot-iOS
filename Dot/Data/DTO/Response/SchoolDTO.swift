//
//  SchoolDTO.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/09/10.
//

import CoreLocation
import Foundation

struct SchoolDTO: Codable {
    let schools: [SchoolItemDTO]
}

struct SchoolItemDTO: Codable {
    let id: Int
    let name: String
    let x: Double
    let y: Double
    let address: String

    var distance: String {
        guard let currentLoc = LocationManager.shared.manager.location else { return "" }
        let distance = currentLoc.distance(from: CLLocation(latitude: y, longitude: x))
        return String(distance).prettyDistance
    }
    
    func toStore() -> Store {
        Store(
            id: self.id,
            name: self.name,
            address: self.address,
            isBookmarked: false,
            distance: self.distance,
            x: self.x,
            y: self.y
        )
    }
}
