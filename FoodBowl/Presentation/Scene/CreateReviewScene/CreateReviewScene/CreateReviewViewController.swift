//
//  CreateReviewViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/09/16.
//

import Combine
import UIKit

import SnapKit
import Then

final class CreateReviewViewController: UIViewController, Navigationable, Keyboardable {
    
    // MARK: - ui component
    
    private let createReviewView: CreateReviewView = CreateReviewView()
    
    // MARK: - property
    
    private let viewModel: any CreateReviewViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    let setStorePublisher = PassthroughSubject<Store, Never>()
    
    // MARK: - init
    
    init(viewModel: any CreateReviewViewModelType) {
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
        self.view = self.createReviewView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.bindUI()
        self.setupNavigation()
        self.setupKeyboardGesture()
    }
    
    // MARK: - func - bind
    
    private func bindViewModel() {
        let output = self.transformedOutput()
        self.configureNavigation()
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> CreateReviewViewModel.Output? {
        guard let viewModel = self.viewModel as? CreateReviewViewModel else { return nil }
        let input = CreateReviewViewModel.Input(
            setStore: self.setStorePublisher.eraseToAnyPublisher(),
            completeButtonDidTap: self.createReviewView.completeButtonDidTapPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: CreateReviewViewModel.Output?) {
        guard let output else { return }
        
        output.isCompleted
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success:
                    self?.makeAlert(
                        title: "후기",
                        message: "후기가 등록되었어요.",
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
        guard let viewModel = self.viewModel as? CreateReviewViewModel else { return }
        
        self.createReviewView.closeButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.makeRequestAlert(
                    title: "후기",
                    message: "후기를 작성하지 않으시나요?",
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
        
        self.createReviewView.searchBarButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.viewModel.presentSearchStoreViewController(location: viewModel.location)
            })
            .store(in: &self.cancellable)
        
        self.createReviewView.makeAlertPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] message in
                self?.makeAlert(title: message)
            })
            .store(in: &self.cancellable)
        
        self.createReviewView.showStorePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] url in
                self?.viewModel.presentShowWebViewController(url: url)
            })
            .store(in: &self.cancellable)
    }
    
    // MARK: - func
    
    private func configureNavigation() {
        guard let navigationController = self.navigationController else { return }
        self.createReviewView.configureNavigationBarItem(navigationController)
    }
}

extension CreateReviewViewController: SearchStoreViewControllerDelegate {
    func setStore(store: Store) {
        self.setStorePublisher.send(store)
        self.createReviewView.setStore(store: store)
    }
}
