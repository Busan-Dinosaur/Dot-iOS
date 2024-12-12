//
//  Double+Extension.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/15/23.
//

import SwiftUI

extension Double {
    var prettyDistance: String {
        if self >= 1000 {
            return String(format: "%.1fkm", self / 1000)
        } else {
            return String(format: "%dm", Int(self))
        }
    }
}
