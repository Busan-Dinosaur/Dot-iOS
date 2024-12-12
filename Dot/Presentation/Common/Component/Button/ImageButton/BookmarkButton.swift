//
//  BookmarkButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/07/22.
//

import UIKit

final class BookmarkButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                setImage(
                    ImageLiteral.bookmarkFill.resize(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
            } else {
                setImage(
                    ImageLiteral.bookmark.resize(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
            }
        }
    }

    // MARK: - init
    
    override init(frame _: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 30, height: 30)))
        self.configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        self.setImage(ImageLiteral.bookmark.resize(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate), for: .normal)
        self.tintColor = .mainTextColor
    }
}
