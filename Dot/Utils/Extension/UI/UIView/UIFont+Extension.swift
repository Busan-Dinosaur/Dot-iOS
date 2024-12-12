//
//  UIFont+Extension.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import UIKit

extension UIFont {
    static func preferredFont(forTextStyle: TextStyle, weight: Weight) -> UIFont {
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: forTextStyle)
        return UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
    }
}
