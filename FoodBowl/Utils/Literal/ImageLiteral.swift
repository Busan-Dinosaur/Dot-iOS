//
//  ImageLiteral.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import UIKit

enum ImageLiteral {
    
    static var logo: UIImage { .load(name: "logo") }
    
    static var all: UIImage { .load(name: "all") }
    static var allFill: UIImage { .load(name: "all_fill") }
    
    static var friends: UIImage { .load(name: "friends") }
    static var friendsFill: UIImage { .load(name: "friends_fill") }
    
    static var person: UIImage { .load(name: "person") }
    static var personFill: UIImage { .load(name: "person_fill") }
    
    static var bookmark: UIImage { .load(name: "bookmark") }
    static var bookmarkFill: UIImage { .load(name: "bookmark_fill") }
    
    static var search: UIImage { .load(name: "search") }
    static var place: UIImage { .load(name: "place") }
    static var univ: UIImage { .load(name: "univ") }
    static var profile: UIImage { .load(name: "profile") }
    
    static var btnClose: UIImage { .load(systemName: "xmark") }
    static var btnSetting: UIImage { .load(name: "settings") }
    static var btnBack: UIImage { .load(systemName: "chevron.backward") }
    static var btnDown: UIImage { .load(name: "down") }
    static var btnForward: UIImage { .load(systemName: "chevron.forward") }
    static var btnPlus: UIImage { .load(name: "plus") }
    static var btnOption: UIImage { .load(name: "option") }
    static var btnKakaomap: UIImage { .load(name: "kakaomap") }
    static var btnFeed: UIImage { .load(name: "feed") }
    
    static var placeFill: UIImage { .load(name: "place_fill") }

    static var defaultProfile: UIImage { .load(name: "user") }
    static var appleLogo: UIImage { .load(systemName: "apple.logo") }

    static var camera: UIImage { .load(name: "camera") }

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
    
    static var next: UIImage { .load(name: "next") }
    
    // SVG
    static var refresh: UIImage { .load(name: "refresh") }
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
