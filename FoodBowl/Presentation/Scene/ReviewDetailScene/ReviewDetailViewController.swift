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
    
    private let viewModel: any ReviewDetailViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let removeButtonDidTapPublisher = PassthroughSubject<Void, Never>()

    // MARK: - init
    
    init(viewModel: any ReviewDetailViewModelType) {
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
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> ReviewDetailViewModel.Output? {
        guard let viewModel = self.viewModel as? ReviewDetailViewModel else { return nil }
        let input = ReviewDetailViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            bookmarkButtonDidTap: self.reviewDetailView.storeInfoButton.bookmarkButtonDidTapPublisher.eraseToAnyPublisher(),
            removeButtonDidTap: self.removeButtonDidTapPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: ReviewDetailViewModel.Output?) {
        guard let output else { return }
        
        output.review
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let review):
                    self.reviewDetailView.configureReview(review)
                case .failure(let error):
                    self.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.isBookmarked
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.reviewDetailView.storeInfoButton.bookmarkToggle()
                case .failure(let error):
                    self.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.isRemoved
              .receive(on: DispatchQueue.main)
              .sink(receiveValue: { [weak self] result in
                  guard let self = self else { return }
                  switch result {
                  case .success:
                      self.viewModel.dismiss()
                  case .failure(let error):
                      self.makeErrorAlert(
                          title: "에러",
                          error: error
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
                self.viewModel.presentMemberViewController()
            })
            .store(in: &self.cancellable)
        
        self.reviewDetailView.optionButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.presentOptionAlert(
                    onBlame: {
                        self.viewModel.presentBlameViewController()
                    },
                    onUpdate: {
                        self.viewModel.presentUpdateReviewViewController()
                    },
                    onDelete: {
                        self.removeButtonDidTapPublisher.send()
                    }
                )
            })
            .store(in: &self.cancellable)
        
        self.reviewDetailView.storeInfoButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.presentStoreDetailViewController()
            })
            .store(in: &self.cancellable)
        
        self.reviewDetailView.storeInfoButton.mapButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] url in
                guard let self = self else { return }
                self.viewModel.presentShowWebViewController(url: url)
            })
            .store(in: &self.cancellable)
    }
}
