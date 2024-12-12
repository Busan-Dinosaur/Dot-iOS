//
//  CreateBlameRequestDTO.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/12/23.
//

import Foundation

struct CreateBlameRequestDTO: Encodable {
    let targetId: Int
    let blameTarget: String
    let description: String
}
