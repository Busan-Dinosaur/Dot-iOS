//
//  CategoryDTO.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/09/10.
//

import Foundation

struct CategoryDTO: Decodable {
    let categories: [CategoryItemDTO]
}

struct CategoryItemDTO: Decodable {
    let id: Int
    let name: String
}
