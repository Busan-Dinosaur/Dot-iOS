//
//  EmptyView.swift
//  FoodBowl
//
//  Created by Coby on 2/4/24.
//

import UIKit

import SnapKit
import Then

final class EmptyView: UIView, BaseViewType {
    
    // MARK: - ui component

    private let emptyLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .regular)
        $0.textColor = .subTextColor
    }
    let findButton = FindButton()
    
    // MARK: - property
    
    var findButtonTapAction: ((EmptyView) -> Void)?

    // MARK: - init
    
    init(message: String, isFind: Bool = true) {
        super.init(frame: .zero)
        self.baseInit()
        self.emptyLabel.text = message
        self.findButton.isHidden = !isFind
        self.setupAction()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {
        self.addSubviews(
            self.emptyLabel,
            self.findButton
        )
        
        self.emptyLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-60)
        }
        
        self.findButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.emptyLabel.snp.bottom).offset(4)
        }
    }

    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
    
    private func setupAction() {
        self.findButton.addAction(UIAction { _ in self.findButtonTapAction?(self) }, for: .touchUpInside)
    }
}
