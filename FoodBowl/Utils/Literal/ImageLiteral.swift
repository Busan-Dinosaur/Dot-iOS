//
//  ImageLiteral.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import UIKit

enum ImageLiteral {
    static var friends: UIImage { .load(name: "friends") }
    static var bookmark: UIImage { .load(name: "bookmark") }
    static var search: UIImage { .load(name: "search") }
    static var univ: UIImage { .load(name: "univ") }
    static var profile: UIImage { .load(name: "profile") }

    static var bookmarkFill: UIImage { .load(name: "bookmark_fill") }

    static var btnClose: UIImage { .load(systemName: "xmark") }
    static var btnSetting: UIImage { .load(name: "settings") }
    static var btnBack: UIImage { .load(systemName: "chevron.backward") }
    static var btnDown: UIImage { .load(name: "down") }
    static var btnForward: UIImage { .load(systemName: "chevron.forward") }
    static var btnPlus: UIImage { .load(name: "plus") }
    static var btnOption: UIImage { .load(name: "option") }
    static var btnKakaomap: UIImage { .load(name: "kakaomap") }
    static var btnFeed: UIImage { .load(name: "feed") }

    static var defaultProfile: UIImage { .load(name: "user") }
    static var appleLogo: UIImage { .load(systemName: "apple.logo") }

    static var camera: UIImage { .load(name: "camera") }

    static var vegan: UIImage { .load(name: "vegan") }
    static var cafe: UIImage { .load(name: "cafe") }
    static var pub: UIImage { .load(name: "pub") }
    static var korean: UIImage { .load(name: "korean") }
    static var western: UIImage { .load(name: "western") }
    static var japanese: UIImage { .load(name: "japanese") }
    static var chinese: UIImage { .load(name: "chinese") }
    static var chicken: UIImage { .load(name: "chicken") }
    static var snack: UIImage { .load(name: "snack") }
    static var seafood: UIImage { .load(name: "seafood") }
    static var salad: UIImage { .load(name: "salad") }
    static var etc: UIImage { .load(name: "etc") }
}

extension UIImage {
    static func load(name: String) -> UIImage {
        guard let image = UIImage(named: name, in: nil, compatibleWith: nil) else {
            return UIImage()
        }
        image.accessibilityIdentifier = name
        return image
    }

    static func load(systemName: String) -> UIImage {
        guard let image = UIImage(systemName: systemName, compatibleWith: nil) else {
            return UIImage()
        }
        image.accessibilityIdentifier = systemName
        return image
    }

    func resize(to size: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
        return image
    }
}
