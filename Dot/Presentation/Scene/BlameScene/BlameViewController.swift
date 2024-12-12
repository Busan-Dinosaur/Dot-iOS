//
//  BlameViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/13/23.
//

import Combine
import UIKit

import SnapKit
import Then

final class BlameViewController: UIViewController, Keyboardable {
    
    // MARK: - ui component
    
    private let blameView: BlameView = BlameView()
    
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
        self.view = self.blameView
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
    
    private func transformedOutput() -> BlameViewModel.Output? {
        guard let viewModel = self.viewModel as? BlameViewModel else { return nil }
        let input = BlameViewModel.Input(
            completeButtonDidTap: self.blameView.completeButtonDidTapPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: BlameViewModel.Output?) {
        guard let output else { return }
        
        output.isCompleted
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success:
                    self?.makeAlert(
                        title: "신고",
                        message: "신고가 등록되었어요.",
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
        self.blameView.closeButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.makeRequestAlert(
                    title: "신고",
                    message: "신고하지 않으시나요?",
                    okTitle: "네",
                    cancelTitle: "아니요",
                    okAction: { _ in
                        self?.dismiss(animated: true)
                    }
                )
            })
            .store(in: &self.cancellable)
        
        self.blameView.makeAlertPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] message in
                self?.makeAlert(title: message)
            })
            .store(in: &self.cancellable)
    }
    
    // MARK: - func
    
    private func configureNavigation() {
        guard let navigationController = self.navigationController else { return }
        self.blameView.configureNavigationBarItem(navigationController)
    }
}
