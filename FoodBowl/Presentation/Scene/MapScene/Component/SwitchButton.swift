//
//  SwitchButton.swift
//  FoodBowl
//
//  Created by Coby on 12/8/24.
//

import Combine
import UIKit

final class SwitchButton: UIButton {
    
    // MARK: - property
    
    var switchButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.buttonTapPublisher
    }
    
    var currentSwitchType: SwitchType = .all {
        didSet {
            self.updateIcon()
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
        self.tintColor = UIColor.mainBackgroundColor
        self.backgroundColor = UIColor.mainColor
        self.layer.borderColor = UIColor.grey002.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
    
    private func updateIcon() {
        let icon = self.currentSwitchType.icon.resize(to: CGSize(width: 20, height: 20)).withRenderingMode(.alwaysTemplate)
        self.setImage(icon, for: .normal)
    }
}
