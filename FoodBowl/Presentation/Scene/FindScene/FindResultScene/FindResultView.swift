//
//  FindResultView.swift
//  FoodBowl
//
//  Created by Coby on 1/21/24.
//

import Combine
import UIKit

import SnapKit
import Then

final class FindResultView: UIView, BaseViewType {
    
    // MARK: - ui component
    
    let listTableView = UITableView().then {
        $0.register(StoreInfoTableViewCell.self, forCellReuseIdentifier: StoreInfoTableViewCell.className)
        $0.register(UserInfoTableViewCell.self, forCellReuseIdentifier: UserInfoTableViewCell.className)
        $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        $0.backgroundColor = .mainBackgroundColor
    }
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(self.listTableView)

        self.listTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
}
