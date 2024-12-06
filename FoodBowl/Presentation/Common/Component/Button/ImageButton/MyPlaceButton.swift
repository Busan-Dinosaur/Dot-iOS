//
//  MyPlaceButton.swift
//  FoodBowl
//
//  Created by Coby on 2/14/24.
//

import UIKit

final class MyPlaceButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                setImage(
                    ImageLiteral.placeFill.resize(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
                tintColor = .mainBackgroundColor
                backgroundColor = .mainColor
            } else {
                setImage(
                    ImageLiteral.place.resize(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
                tintColor = .mainColor
                backgroundColor = .mainBackgroundColor
            }
        }
    }

    // MARK: - init
    
    override init(frame _: CGRect) {
        super.init(frame: .init(origin: .zero, size: .init(width: 30, height: 30)))
        self.configureUI()
        self.setupAction()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        self.isSelected = false
    }
    
    private func setupAction() {
        self.addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(handleTouchUpInside), for: .touchUpInside)
        self.addTarget(self, action: #selector(handleTouchUpOutside), for: .touchUpOutside)
    }
    
    @objc private func handleTouchDown() {
        // 사용자가 버튼을 누르는 순간의 색상 변경
        self.isSelected = true
    }
    
    @objc private func handleTouchUpInside() {
        // 사용자가 버튼을 떼는 순간의 색상 복원
        self.isSelected = false
    }
    
    @objc private func handleTouchUpOutside() {
        // 사용자가 버튼 밖에서 손을 떼는 순간의 색상 복원
        self.isSelected = false
    }
}
