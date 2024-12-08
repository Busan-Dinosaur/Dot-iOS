//
//  SettingView.swift
//  FoodBowl
//
//  Created by Coby on 1/21/24.
//

import UIKit

import SnapKit
import Then

final class SettingView: UIView, BaseViewType {

    // MARK: - ui component
    
    let listTableView = UITableView().then {
        $0.register(SettingItemTableViewCell.self, forCellReuseIdentifier: SettingItemTableViewCell.className)
        $0.separatorStyle = .none
        $0.backgroundColor = .mainBackgroundColor
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
    
    // MARK: - func
    
    func configureNavigationBarTitle(_ navigationController: UINavigationController) {
        let navigationItem = navigationController.topViewController?.navigationItem
        navigationItem?.title = "설정"
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
