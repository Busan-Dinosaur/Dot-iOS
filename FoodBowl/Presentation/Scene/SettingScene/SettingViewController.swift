//
//  SettingViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/26.
//

import Combine
import UIKit

import SnapKit
import Then

final class SettingViewController: UIViewController, Navigationable {
    
    // MARK: - ui component
    
    private let settingView: SettingView = SettingView()
    
    // MARK: - property
    
    private let viewModel: any SettingViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let viewWillAppearPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    private let logOutPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    private let signOutPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private var options: [Option] {[
        Option(
            title: "개인정보처리방침",
            handler: { [weak self] in
                self?.viewModel.presentShowWebViewController(url: "https://coby5502.notion.site/2ca079dd7b354cd790b3280728ebb0d5")
            }
        ),
        Option(
            title: "이용약관",
            handler: { [weak self] in
                self?.viewModel.presentShowWebViewController(url: "https://coby5502.notion.site/32da9811cd284eaab7c3d8390c0ddccc")
            }
        ),
        Option(
            title: "로그아웃",
            handler: { [weak self] in
                self?.makeRequestAlert(
                    title: "로그아웃",
                    message: "로그아웃 하시겠어요?",
                    okTitle: "네",
                    cancelTitle: "아니요",
                    okAction: { _ in
                        self?.logOutPublisher.send(())
                    }
                )
            }
        ),
        Option(
            title: "탈퇴하기",
            handler: { [weak self] in
                self?.makeRequestAlert(
                    title: "탈퇴",
                    message: "정말 탈퇴하시나요?",
                    okTitle: "네",
                    cancelTitle: "아니요",
                    okAction: { _ in
                        self?.signOutPublisher.send(())
                    }
                )
            }
        ),
    ]}
    
    // MARK: - init
    
    init(viewModel: any SettingViewModelType) {
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
        self.view = self.settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigation()
        self.configureDelegation()
        self.bindViewModel()
        self.bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewWillAppearPublisher.send(())
    }
    
    // MARK: - func - bind
    
    private func bindViewModel() {
        let output = self.transformedOutput()
        self.configureNavigation()
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> SettingViewModel.Output? {
        guard let viewModel = self.viewModel as? SettingViewModel else { return nil }
        let input = SettingViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            viewWillAppear: self.viewWillAppearPublisher.eraseToAnyPublisher(),
            logOut: self.logOutPublisher.eraseToAnyPublisher(),
            signOut: self.signOutPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: SettingViewModel.Output?) {
        guard let output else { return }
        
        output.member
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let member):
                    guard let self = self else { return }
                    self.settingView.profileView().configureProfile(member: member)
                    self.configureNavigation(member.nickname)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.isLogOut
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success:
                    guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
                    sceneDelegate.moveToSignViewController()
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.isSignOut
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success:
                    guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
                    sceneDelegate.moveToSignViewController()
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
    
    private func configureDelegation() {
        self.settingView.settingListView().delegate = self
        self.settingView.settingListView().dataSource = self
    }
    
    private func configureNavigation(_ title: String = "") {
        guard let navigationController = self.navigationController else { return }
        self.settingView.configureNavigationBarItem(navigationController, title)
    }
    
    private func bindUI() {
        self.settingView.profileView().editButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.viewModel.presentUpdateProfileViewController()
            })
            .store(in: &self.cancellable)
        
        self.settingView.profileView().followerButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.viewModel.presentFollowerViewController()
            })
            .store(in: &self.cancellable)
        
        self.settingView.profileView().followingButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.viewModel.presentFollowingViewController()
            })
            .store(in: &self.cancellable)
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: SettingItemTableViewCell.className, for: indexPath) as? SettingItemTableViewCell
        else { return UITableViewCell() }

        cell.selectionStyle = .none
        cell.menuLabel.text = options[indexPath.item].title

        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        options[indexPath.item].handler()
    }
}
