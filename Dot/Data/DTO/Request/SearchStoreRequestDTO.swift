//
//  SearchStoreRequestDTO.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/12/23.
//

import Foundation

struct SearchStoreRequestDTO: Encodable {
    let name: String
    let x: Double
    let y: Double
    let size: Int
}
