//
//  GetStoresRequestDTO.swift
//  FoodBowl
//
//  Created by Coby on 12/29/23.
//

struct GetStoresBySchoolRequestDTO: Encodable {
    let location: CustomLocationRequestDTO
    
    let schoolId: Int
}

struct GetStoresByMemberRequestDTO: Encodable {
    let location: CustomLocationRequestDTO
    
    let memberId: Int
}
