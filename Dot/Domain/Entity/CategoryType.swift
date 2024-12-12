//
//  CategoryType.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/17/23.
//

import UIKit

enum CategoryType: String, CaseIterable {
    case cafe = "카페"
    case pub = "술집"
    case korean = "한식"
    case western = "양식"
    case japanese = "일식"
    case chinese = "중식"
    case chicken = "치킨"
    case snack = "분식"
    case seafood = "해산물"
    case salad = "샐러드"
    case etc = "기타"

    var icon: UIImage {
        switch self {
        case .cafe:
            return ImageLiteral.cafe
        case .pub:
            return ImageLiteral.pub
        case .korean:
            return ImageLiteral.korean
        case .western:
            return ImageLiteral.western
        case .japanese:
            return ImageLiteral.japanese
        case .chinese:
            return ImageLiteral.chinese
        case .chicken:
            return ImageLiteral.chicken
        case .snack:
            return ImageLiteral.snack
        case .seafood:
            return ImageLiteral.seafood
        case .salad:
            return ImageLiteral.salad
        case .etc:
            return ImageLiteral.etc
        }
    }
}
