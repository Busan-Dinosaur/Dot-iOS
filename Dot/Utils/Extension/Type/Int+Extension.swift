//
//  Int+Extension.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/15/23.
//

import SwiftUI

extension Int {
    var prettyNumber: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1

        var result = ""

        switch self {
        case 0..<1_000:
            result = "\(self)"
        case 1_000..<1_000_000:
            let value = Double(self) / 1_000
            formatter.numberStyle = .decimal
            result = formatter.string(from: NSNumber(value: value)) ?? ""
            result += "k"
        case 1_000_000..<1_000_000_000:
            let value = Double(self) / 1_000_000
            formatter.numberStyle = .decimal
            result = formatter.string(from: NSNumber(value: value)) ?? ""
            result += "m"
        default:
            let value = Double(self) / 1_000_000_000
            formatter.numberStyle = .decimal
            result = formatter.string(from: NSNumber(value: value)) ?? ""
            result += "b"
        }

        return result
    }
}
