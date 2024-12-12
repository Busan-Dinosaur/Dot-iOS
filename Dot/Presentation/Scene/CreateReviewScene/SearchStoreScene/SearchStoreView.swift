//
//  SearchStoreView.swift
//  FoodBowl
//
//  Created by Coby on 1/18/24.
//

import Combine
import UIKit

import SnapKit
import Then

final class SearchStoreView: UIView, BaseViewType {
    
    // MARK: - ui component
    
    let searchBar = UISearchBar().then {
        $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 80, height: 0)
        $0.placeholder = "검색"
    }
    private let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(.mainColor, for: .normal)
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline, weight: .regular)
    }
    private let listTableView = UITableView().then {
        $0.register(StoreTableViewCell.self, forCellReuseIdentifier: StoreTableViewCell.className)
        $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        $0.backgroundColor = .clear
    }
    
    // MARK: - property
    
    var cancelButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.cancelButton.buttonTapPublisher
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
    
    // MARK: - func
    
    func configureNavigationBarItem(_ navigationController: UINavigationController) {
        let navigationItem = navigationController.topViewController?.navigationItem
        let cancelButton = navigationController.makeBarButtonItem(with: cancelButton)
        navigationItem?.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        navigationItem?.rightBarButtonItem = cancelButton
    }
    
    func tableView() -> UITableView {
        return self.listTableView
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
