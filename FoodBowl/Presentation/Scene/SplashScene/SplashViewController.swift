//
//  SplashViewController.swift
//  FoodBowl
//
//  Created by Coby on 2/1/24.
//

import Combine
import UIKit

import SnapKit
import Then

final class SplashViewController: UIViewController {
    
    // MARK: - ui component
    
    private let splashView: SplashView = SplashView()
    
    // MARK: - property
    
    private let viewModel: any SplashViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    // MARK: - init
    
    init(viewModel: any SplashViewModelType) {
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
        self.view = self.splashView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
    }

    // MARK: - func
    
    private func bindViewModel() {
        let output = self.transformedOutput()
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> SplashViewModel.Output? {
        guard let viewModel = self.viewModel as? SplashViewModel else { return nil }
        let input = SplashViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: SplashViewModel.Output?) {
        guard let output else { return }
        
        output.isLogin
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let isLogin):
                    switch isLogin {
                    case true:
                        self?.viewModel.presentTabViewController()
                    case false:
                        self?.viewModel.presentSignViewController()
                    }
                case .failure:
                    self?.makeAlert(title: "인터넷 연결을 확인해주세요.")
                }
            })
            .store(in: &self.cancellable)
    }
}
