//
//  ReviewDetailViewController.swift
//  FoodBowl
//
//  Created by Coby on 1/24/24.
//

import Combine
import UIKit

import SnapKit
import Then

final class ReviewDetailViewController: UIViewController, Navigationable, Optionable {
    
    // MARK: - ui component
    
    private let reviewDetailView: ReviewDetailView = ReviewDetailView()
    
    // MARK: - property
    
    private let viewModel: any BaseViewModelType
    private var cancellable: Set<AnyCancellable> = Set()

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
        self.view = self.reviewDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.bindUI()
        self.setupNavigation()
    }
    
    // MARK: - func - bind

    private func bindViewModel() {
        let output = self.transformedOutput()
        self.configureNavigation()
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> ReviewDetailViewModel.Output? {
        guard let viewModel = self.viewModel as? ReviewDetailViewModel else { return nil }
        let input = ReviewDetailViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            bookmarkButtonDidTap: self.reviewDetailView.bookmarkButtonDidTapPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: ReviewDetailViewModel.Output?) {
        guard let output else { return }
        
        output.review
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let review):
                    self?.reviewDetailView.configureReview(review)
                case .failure(let error):
                    self?.makeAlert(
                        title: "에러",
                        message: error.localizedDescription
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.isBookmark
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success:
                    self?.reviewDetailView.storeInfoButton.bookmarkButton.isSelected.toggle()
                case .failure(let error):
                    self?.makeAlert(
                        title: "에러",
                        message: error.localizedDescription
                    )
                }
            })
            .store(in: &self.cancellable)
    }
    
    private func bindUI() {
        self.reviewDetailView.userInfoButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                guard let viewModel = self.viewModel as? ReviewDetailViewModel else { return }
                self.presentProfileViewController(id: viewModel.memberId)
            })
            .store(in: &self.cancellable)
        
        self.reviewDetailView.optionButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self,
                      let viewModel = self.viewModel as? ReviewDetailViewModel else { return }
                self.presentReviewOptionAlert(
                    reviewId: viewModel.reviewId,
                    isMyReview: viewModel.reviewId == UserDefaultStorage.id
                )
            })
            .store(in: &self.cancellable)
        
        self.reviewDetailView.storeInfoButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                guard let viewModel = self.viewModel as? ReviewDetailViewModel else { return }
                self.presentStoreDetailViewController(id: viewModel.storeId)
            })
            .store(in: &self.cancellable)
    }
    
    // MARK: - func
    
    private func configureNavigation() {
        guard let navigationController = self.navigationController else { return }
        self.reviewDetailView.configureNavigationBarTitle(navigationController)
    }
}

// MARK: - Helper
extension ReviewDetailViewController {
    private func presentProfileViewController(id: Int) {
        let repository = ProfileRepositoryImpl()
        let usecase = ProfileUsecaseImpl(repository: repository)
        let viewModel = ProfileViewModel(
            usecase: usecase,
            memberId: id
        )
        let viewController = ProfileViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentStoreDetailViewController(id: Int) {
        let repository = StoreDetailRepositoryImpl()
        let usecase = StoreDetailUsecaseImpl(repository: repository)
        let viewModel = StoreDetailViewModel(
            usecase: usecase,
            storeId: id
        )
        let viewController = StoreDetailViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
