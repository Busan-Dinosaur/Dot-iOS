//
//  UpdateReviewViewController.swift
//  FoodBowl
//
//  Updated by COBY_PRO on 2023/09/12.
//

import Combine
import UIKit

import Kingfisher
import SnapKit
import Then

final class UpdateReviewViewController: UIViewController, Keyboardable {
    
    // MARK: - ui component
    
    private let updateReviewView: UpdateReviewView = UpdateReviewView()
    
    // MARK: - property
    
    private var cancellable: Set<AnyCancellable> = Set()
    private let viewModel: any UpdateReviewViewModelType
    
    private var reviewImages = [UIImage]()

    // MARK: - init
    
    init(viewModel: any UpdateReviewViewModelType) {
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
        self.view = self.updateReviewView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    private func transformedOutput() -> UpdateReviewViewModel.Output? {
        guard let viewModel = self.viewModel as? UpdateReviewViewModel else { return nil }
        let input = UpdateReviewViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            completeButtonDidTap: self.updateReviewView.completeButtonDidTapPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: UpdateReviewViewModel.Output?) {
        guard let output else { return }
        
        output.review
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let review):
                    guard let self = self else { return }
                    self.updateReviewView.configureReview(review)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.isCompleted
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success:
                    self?.makeAlert(
                        title: "후기",
                        message: "후기가 수정되었어요.",
                        okAction: { _ in
                            DispatchQueue.main.async { [weak self] in
                                self?.viewModel.dismiss()
                            }
                        }
                    )
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
        self.updateReviewView.closeButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.makeRequestAlert(
                    title: "후기",
                    message: "후기를 수정하지 않으시나요?",
                    okTitle: "네",
                    cancelTitle: "아니요",
                    okAction: { _ in
                        DispatchQueue.main.async { [weak self] in
                            self?.viewModel.dismiss()
                        }
                    }
                )
            })
            .store(in: &self.cancellable)
        
        self.updateReviewView.makeAlertPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] message in
                self?.makeAlert(title: message)
            })
            .store(in: &self.cancellable)
        
        self.updateReviewView.selectedStore().mapButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] url in
                self?.viewModel.presentShowWebViewController(url: url)
            })
            .store(in: &self.cancellable)
    }
    
    // MARK: - func
    
    private func configureNavigation() {
        guard let navigationController = self.navigationController else { return }
        self.updateReviewView.configureNavigationBarItem(navigationController)
    }
}
