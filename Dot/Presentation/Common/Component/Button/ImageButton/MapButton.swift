//
//  MapButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/07/22.
//

import UIKit

final class MapButton: UIButton {
    
    // MARK: - init
    
    override init(frame _: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 40, height: 40)))
        self.configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        self.setImage(ImageLiteral.btnKakaomap.resize(to: CGSize(width: 40, height: 40)), for: .normal)
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
    }
}
