//
//  UpdateProfileViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/26.
//

import Combine
import UIKit

import SnapKit
import Then

final class UpdateProfileViewController: UIViewController, Navigationable, Keyboardable, PhotoPickerable {
    
    // MARK: - ui component
    
    private let updateProfileView: UpdateProfileView = UpdateProfileView()
    
    // MARK: - property
    
    private let viewModel: any BaseViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    let setProfileImagePublisher = PassthroughSubject<UIImage, Never>()
    
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
        self.view = self.updateProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.bindUI()
        self.setupNavigation()
        self.setupKeyboardGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - func - bind
    
    private func bindViewModel() {
        let output = self.transformedOutput()
        self.configureNavigation()
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> UpdateProfileViewModel.Output? {
        guard let viewModel = self.viewModel as? UpdateProfileViewModel else { return nil }
        let input = UpdateProfileViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            setProfileImage: self.setProfileImagePublisher.eraseToAnyPublisher(),
            completeButtonDidTap: self.updateProfileView.completeButtonDidTapPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: UpdateProfileViewModel.Output?) {
        guard let output else { return }
        
        output.profile
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let profile):
                    self?.updateProfileView.configureView(member: profile)
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
                        title: "프로필",
                        message: "프로필이 변경되었어요.",
                        okAction: { _ in
                            self?.navigationController?.popViewController(animated: true)
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
        self.updateProfileView.profileImageButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.photoAddButtonDidTap()
            })
            .store(in: &self.cancellable)
        
        self.updateProfileView.makeAlertPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] message in
                self?.makeAlert(title: message)
            })
            .store(in: &self.cancellable)
    }
    
    // MARK: - func
    
    private func configureNavigation() {
        guard let navigationController = self.navigationController else { return }
        self.updateProfileView.configureNavigationBarTitle(navigationController)
    }
    
    func setPhoto(image: UIImage) {
        self.updateProfileView.profileImageButton.setImage(image, for: .normal)
        self.setProfileImagePublisher.send(image)
    }
}
