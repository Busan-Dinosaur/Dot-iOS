//
//  SwitchType.swift
//  FoodBowl
//
//  Created by Coby on 12/8/24.
//

import UIKit

enum SwitchType: CaseIterable {
    
    case all
    case friends
    case person
    case bookmark
    
    var icon: UIImage {
        switch self {
        case .all:
            return ImageLiteral.allFill
        case .friends:
            return ImageLiteral.friendsFill
        case .person:
            return ImageLiteral.personFill
        case .bookmark:
            return ImageLiteral.bookmarkFill
        }
    }
    
    var nextType: SwitchType {
        switch self {
        case .all:
            return .friends
        case .friends:
            return .person
        case .person:
            return .bookmark
        case .bookmark:
            return .all
        }
    }
}
