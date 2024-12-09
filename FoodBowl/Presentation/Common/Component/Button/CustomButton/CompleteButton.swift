//
//  CompleteButton.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import UIKit

import SnapKit
import Then

final class CompleteButton: UIButton, BaseViewType {
    
    override var isEnabled: Bool {
        didSet {
            self.alpha = self.isEnabled ? 1.0 : 0.3
        }
    }
    
    // MARK: - ui component

    let label = UILabel().then {
        let label = UILabel()
        $0.textColor = .white
        $0.font = UIFont.preferredFont(forTextStyle: .body, weight: .semibold)
        $0.text = "완료"
    }

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - life cycle

    func setupLayout() {
        self.addSubview(self.label)

        self.label.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        self.snp.makeConstraints {
            $0.height.equalTo(44)
        }
    }

    func configureUI() {
        self.isEnabled = false
        self.backgroundColor = .mainColor
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = false
    }
}
