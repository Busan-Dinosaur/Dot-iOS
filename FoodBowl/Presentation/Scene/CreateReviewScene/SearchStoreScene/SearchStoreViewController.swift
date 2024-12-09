//
//  SearchStoreViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/09/16.
//

import Combine
import UIKit

import SnapKit
import Then

final class SearchStoreViewController: UIViewController, Keyboardable, Helperable {
    
    // MARK: - ui component
    
    private let searchStoreView: SearchStoreView = SearchStoreView()
    private let emptyView = EmptyListView().then {
        $0.configureEmptyView(
            message: "검색된 가게가 없어요.",
            isFind: false
        )
    }
    
    // MARK: - property
    
    private var stores: [Store] = []
    
    private let viewModel: any BaseViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    let searchStoresPublisher = PassthroughSubject<String, Never>()
    
    weak var delegate: SearchStoreViewControllerDelegate?
    
    // MARK: - init
    
    init(viewModel: any BaseViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(#file) is dead")
    }
    
    // MARK: - life cycle
    
    override func loadView() {
        self.view = self.searchStoreView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDelegation()
        self.bindViewModel()
        self.bindUI()
        self.setupKeyboardGesture()
    }
    
    // MARK: - func - bind
    
    private func bindViewModel() {
        let output = self.transformedOutput()
        self.configureNavigation()
        self.bindOutputToViewModel(output)
    }

    private func transformedOutput() -> SearchStoreViewModel.Output? {
        guard let viewModel = self.viewModel as? SearchStoreViewModel else { return nil }
        let input = SearchStoreViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            searchStores: self.searchStoresPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: SearchStoreViewModel.Output?) {
        guard let output else { return }

        output.stores
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let stores):
                    self?.stores = stores
                    self?.searchStoreView.tableView().reloadData()
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
    }
    
    private func bindUI() {
        self.searchStoreView.cancelButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.dissmissKeyboard()
                self?.navigationController?.popViewController(animated: true)
            })
            .store(in: &self.cancellable)
    }
    
    // MARK: - func
    
    private func configureDelegation() {
        self.searchStoreView.searchBar.delegate = self
        self.searchStoreView.tableView().delegate = self
        self.searchStoreView.tableView().dataSource = self
    }
    
    private func configureNavigation() {
        guard let navigationController = self.navigationController else { return }
        self.searchStoreView.configureNavigationBarItem(navigationController)
    }
}

extension SearchStoreViewController: UISearchBarDelegate {
    private func dissmissKeyboard() {
        self.searchStoreView.searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.dissmissKeyboard()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.stores = []
            self.searchStoreView.tableView().reloadData()
        } else {
            self.searchStoresPublisher.send(searchText)
        }
    }
}

extension SearchStoreViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.stores.count == 0 {
//            let emptyView = EmptyListView
//            emptyView.findButtonTapAction = { [weak self] _ in
//                self?.presentRecommendViewController()
//            }
//            
            self.searchStoreView.tableView().backgroundView = self.emptyView
        } else {
            self.searchStoreView.tableView().backgroundView = nil
        }
        
        return self.stores.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: StoreTableViewCell.className, for: indexPath) as? StoreTableViewCell
        else { return UITableViewCell() }

        cell.selectionStyle = .none
        cell.configureCell(self.stores[indexPath.item])

        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.setStore(store: self.stores[indexPath.item])
        self.dissmissKeyboard()
        self.navigationController?.popViewController(animated: true)
    }
}

protocol SearchStoreViewControllerDelegate: AnyObject {
    func setStore(store: Store)
}
