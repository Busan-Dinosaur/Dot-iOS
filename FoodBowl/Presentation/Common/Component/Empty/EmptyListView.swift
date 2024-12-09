//
//  EmptyListView.swift
//  FoodBowl
//
//  Created by Coby on 2/4/24.
//

import Combine
import UIKit

import SnapKit
import Then

final class EmptyListView: UIView, BaseViewType {
    
    // MARK: - ui component

    private let emptyLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .regular)
        $0.textColor = .subTextColor
    }
    private let findButton = FindButton()
    
    // MARK: - property
    
    var findButtonTapPublisher: AnyPublisher<Void, Never> {
        return self.findButton.buttonTapPublisher
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
    
    func configureEmptyView(message: String, isFind: Bool = true) {
        self.emptyLabel.text = message
        self.findButton.isHidden = !isFind
    }
}
