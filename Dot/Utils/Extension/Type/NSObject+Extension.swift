//
//  NSObject+Extension.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}
