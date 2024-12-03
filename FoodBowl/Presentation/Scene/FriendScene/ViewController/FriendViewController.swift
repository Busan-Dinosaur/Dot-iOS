//
//  FriendViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/07/18.
//

import UIKit

import SnapKit
import Then

final class FriendViewController: OriginalMapViewController {
    
    // MARK: - ui component

    private let friendLabel = PaddingLabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .bold)
        $0.textColor = .mainTextColor
        $0.text = "친구들"
        $0.padding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        $0.frame = CGRect(x: 0, y: 0, width: 150, height: 0)
    }

    override func configureUI() {
        super.configureUI()
        self.bookmarkButton.isHidden = false
    }
    
    // MARK: - func - bind
    
    override func bindViewModel() {
        let output = self.transformedOutput()
        self.configureNavigation()
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> FriendViewModel.Output? {
        guard let viewModel = self.viewModel as? FriendViewModel else { return nil }
        let input = FriendViewModel.Input(
            setCategory: self.categoryListView.setCategoryPublisher.eraseToAnyPublisher(),
            customLocation: self.locationPublisher.eraseToAnyPublisher(),
            bookmarkToggleButtonDidTap: self.bookmarkToggleButtonDidTapPublisher.eraseToAnyPublisher(),
            bookmarkButtonDidTap: self.bookmarkButtonDidTapPublisher.eraseToAnyPublisher(),
            scrolledToBottom: self.feedListView.collectionView().scrolledToBottomPublisher.eraseToAnyPublisher(),
            refreshControl: self.feedListView.refreshPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: FriendViewModel.Output?) {
        guard let output else { return }
        
        output.stores
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let stores):
                    self?.setupMarkers(stores)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.reviews
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let reviews):
                    self?.loadReviews(reviews)
                    self?.feedListView.refreshControl().endRefreshing()
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
        
        output.isBookmarked
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let storeId):
                    self?.updateBookmark(storeId)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
    }
    
    // MARK: - func
    
    func configureNavigation() {
        let friendLabel = makeBarButtonItem(with: self.friendLabel)
        let plusButton = makeBarButtonItem(with: self.plusButton)
        self.navigationItem.leftBarButtonItem = friendLabel
        self.navigationItem.rightBarButtonItem = plusButton
    }
}
