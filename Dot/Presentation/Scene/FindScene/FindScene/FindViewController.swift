//
//  FindViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/07/24.
//

import Combine
import UIKit

import Kingfisher
import SnapKit
import Then

final class FindViewController: UIViewController, Navigationable, Keyboardable {
    
    enum Section: CaseIterable {
        case main
    }
    
    // MARK: - ui component
    
    private let findView: FindView = FindView()
    private let emptyMemberView = EmptyListView().then {
        $0.configureEmptyView(message: "검색된 유저가 없어요.")
    }
    
    // MARK: - property
    
    private let viewModel: any FindViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Review>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, Review>!
    
    private var scope: Int = 0
    private var stores: [Store] = []
    private var members: [Member] = []
    
    private let searchStoresAndMembersPublisher = PassthroughSubject<String, Never>()
    private let followButtonDidTapPublisher = PassthroughSubject<(Int, Bool), Never>()
    
    // MARK: - init
    
    init(viewModel: any FindViewModelType) {
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
        self.view = self.findView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.setupKeyboardGesture()
        self.configureDataSource()
        self.configureDelegation()
        self.bindViewModel()
        self.bindUI()
    }
    
    // MARK: - func - bind
    
    private func bindViewModel() {
        let output = self.transformedOutput()
        self.configureNavigation()
        self.bindOutputToViewModel(output)
    }

    private func transformedOutput() -> FindViewModel.Output? {
        guard let viewModel = self.viewModel as? FindViewModel else { return nil }
        let input = FindViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            scrolledToBottom: self.findView.collectionView().scrolledToBottomPublisher.eraseToAnyPublisher(),
            refreshControl: self.findView.refreshPublisher.eraseToAnyPublisher(),
            searchStoresAndMembers: self.searchStoresAndMembersPublisher.eraseToAnyPublisher(),
            followMember: self.followButtonDidTapPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: FindViewModel.Output?) {
        guard let output else { return }
        
        output.reviews
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let reviews):
                    self?.loadReviews(reviews)
                    self?.findView.refreshControl().endRefreshing()
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.moreReviews
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let reviews):
                    self?.loadMoreReviews(reviews)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.storesAndMembers
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success((let stores, let members)):
                    self?.stores = stores
                    self?.members = members
                    self?.findView.findResultViewController.findResultView.listTableView.reloadData()
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.followMember
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let memberId):
                    self?.followMember(memberId: memberId)
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
        self.emptyMemberView.findButtonTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.presentRecommendViewController()
            })
            .store(in: &self.cancellable)
    }
    
    // MARK: - func
    
    private func configureDelegation() {
        self.findView.findResultViewController.findResultView.listTableView.delegate = self
        self.findView.findResultViewController.findResultView.listTableView.dataSource = self
        self.findView.searchController.searchResultsUpdater = self
        self.findView.searchController.searchBar.delegate = self
    }
    
    private func configureNavigation() {
        guard let navigationController = self.navigationController else { return }
        self.findView.configureNavigationBarItem(navigationController)
    }
    
    private func followMember(memberId: Int) {
        if let index = self.members.firstIndex(where: { $0.id == memberId }) {
            self.members[index].isFollowing.toggle()
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = self.findView.findResultViewController.findResultView.listTableView.cellForRow(at: indexPath) as? UserInfoTableViewCell {
                cell.followButton.isSelected = self.members[index].isFollowing
            }
        }
    }
}

// MARK: - DataSource
extension FindViewController {
    private func configureDataSource() {
        self.dataSource = self.feedCollectionViewDataSource()
        self.configureSnapshot()
    }

    private func feedCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Section, Review> {
        let reviewCellRegistration = UICollectionView.CellRegistration<PhotoCollectionViewCell, Review> { cell, indexPath, item in
            let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: 100, height: 100), mode: .aspectFill)
            
            cell.imageView.kf.setImage(
                with: URL(string: item.thumbnail),
                options: [
                    .processor(resizingProcessor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
            
            cell.cellTapAction = { [weak self] _ in
                self?.viewModel.presentReviewDetailViewController(id: item.comment.id)
            }
            cell.setupAction()
        }

        return UICollectionViewDiffableDataSource(
            collectionView: self.findView.collectionView(),
            cellProvider: { collectionView, indexPath, item in
                return collectionView.dequeueConfiguredReusableCell(
                    using: reviewCellRegistration,
                    for: indexPath,
                    item: item
                )
            }
        )
    }
}

// MARK: - Snapshot
extension FindViewController {
    private func configureSnapshot() {
        self.snapshot = NSDiffableDataSourceSnapshot<Section, Review>()
        self.snapshot.appendSections([.main])
        self.dataSource.apply(self.snapshot, animatingDifferences: true)
    }
    
    private func loadReviews(_ items: [Review]) {
        let previousReviewsData = self.snapshot.itemIdentifiers(inSection: .main)
        self.snapshot.deleteItems(previousReviewsData)
        self.snapshot.appendItems(items, toSection: .main)
        self.dataSource.applySnapshotUsingReloadData(self.snapshot) {
            let emptyView = EmptyListView()
            emptyView.configureEmptyView(message: "사진이 첨부된 후기가 없어요.")
            
            if self.snapshot.numberOfItems == 0 {
                self.findView.collectionView().backgroundView = emptyView
            } else {
                self.findView.collectionView().backgroundView = nil
            }
        }
    }
    
    private func loadMoreReviews(_ items: [Review]) {
        self.snapshot.appendItems(items, toSection: .main)
        self.dataSource.applySnapshotUsingReloadData(self.snapshot)
    }
}

extension FindViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased(), text != "" else { return }
        self.searchStoresAndMembersPublisher.send(text)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.findView.searchController.searchBar.showsScopeBar = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.findView.searchController.searchBar.showsScopeBar = false
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.scope = selectedScope
        self.findView.findResultViewController.findResultView.listTableView.reloadData()
    }
}

extension FindViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if self.scope == 0 {
            if self.stores.count == 0 {
                let emptyView = EmptyListView()
                emptyView.configureEmptyView(
                    message: "검색된 맛집이 없어요.",
                    isFind: false
                )
                
                self.findView.findResultViewController.findResultView.listTableView.backgroundView = emptyView
            } else {
                self.findView.findResultViewController.findResultView.listTableView.backgroundView = nil
            }
            
            return self.stores.count
        } else {
            if self.members.count == 0 {
                self.findView.findResultViewController.findResultView.listTableView.backgroundView = self.emptyMemberView
            } else {
                self.findView.findResultViewController.findResultView.listTableView.backgroundView = nil
            }
            
            return self.members.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.scope == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: StoreInfoTableViewCell.className,
                for: indexPath
            ) as? StoreInfoTableViewCell else {
                return UITableViewCell()
            }

            cell.selectionStyle = .none
            cell.configureCell(self.stores[indexPath.item])

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: UserInfoTableViewCell.className,
                for: indexPath
            ) as? UserInfoTableViewCell else {
                return UITableViewCell()
            }
            
            cell.selectionStyle = .none
            cell.configureCell(self.members[indexPath.item])
            cell.followButtonTapAction = { [weak self] _ in
                guard let self = self else { return }
                self.followButtonDidTapPublisher.send((self.members[indexPath.item].id, self.members[indexPath.item].isFollowing))
            }

            return cell
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 64
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.scope == 0 {
            self.viewModel.presentStoreDetailViewController(id: self.stores[indexPath.item].id)
        } else {
            self.viewModel.presentMemberViewController(id: self.members[indexPath.item].id)
        }
    }
}
