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

final class CreateReviewViewController: UIViewController, Navigationable, Keyboardable, Helperable {
    
    // MARK: - ui component
    
    private let createReviewView: CreateReviewView = CreateReviewView()
    
    // MARK: - property
    
    private let viewModel: any BaseViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    let setStorePublisher = PassthroughSubject<(Store, Store?), Never>()
    
    weak var delegate: CreateReviewViewControllerDelegate?
    
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
                    self?.delegate?.updateData()
                    self?.makeAlert(
                        title: "후기",
                        message: "후기가 등록되었어요.",
                        okAction: { _ in
                            self?.dismiss(animated: true)
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
                        self?.dismiss(animated: true)
                    }
                )
            })
            .store(in: &self.cancellable)
        
        self.createReviewView.searchBarButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.presentSearchStoreViewController(location: viewModel.location)
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
                self?.presentShowWebViewController(url: url)
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
    func setStore(store: Store, univ: Store?) {
        self.setStorePublisher.send((store, univ))
        self.createReviewView.setStore(store: store)
    }
}

protocol CreateReviewViewControllerDelegate: AnyObject {
    func updateData()
}
