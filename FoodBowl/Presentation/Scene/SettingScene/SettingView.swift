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
    
    private let myProfileView = MyProfileView()
    
    private let listTableView = UITableView().then {
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
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(
            self.myProfileView,
            self.listTableView
        )
        
        self.myProfileView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }

        self.listTableView.snp.makeConstraints {
            $0.top.equalTo(self.myProfileView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
    
    // MARK: - func
    
    func configureNavigationBarItem(
        _ navigationController: UINavigationController,
        _ title: String = ""
    ) {
        guard let navigationItem = navigationController.topViewController?.navigationItem else { return }
        navigationItem.title = title
    }
    
    func profileView() -> MyProfileView {
        self.myProfileView
    }
    
    func settingListView() -> UITableView {
        self.listTableView
    }
}
