//
//  UpdateMemberProfileRequestDTO.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/09/05.
//

import Foundation

struct UpdateMemberProfileRequestDTO: Encodable {
    let nickname: String
    let introduction: String
}
