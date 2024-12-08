//
//  SettingViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/26.
//

import Combine
import MessageUI
import UIKit

import SnapKit
import Then

final class SettingViewController: UIViewController, Navigationable, Helperable {
    
    // MARK: - ui component
    
    private let settingView: SettingView = SettingView()
    
    // MARK: - property
    
    private let viewModel: any BaseViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    private let logOutPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    private let signOutPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private var options: [Option] {[
//        Option(
//            title: "공지사항",
//            handler: { [weak self] in
//                self?.presentShowWebViewController(url: "https://coby5502.notion.site/a25fe63009d24b958fe77ab87e53994e")
//            }
//        ),
        Option(
            title: "개인정보처리방침",
            handler: { [weak self] in
                self?.presentShowWebViewController(url: "https://coby5502.notion.site/2ca079dd7b354cd790b3280728ebb0d5")
            }
        ),
        Option(
            title: "이용약관",
            handler: { [weak self] in
                self?.presentShowWebViewController(url: "https://coby5502.notion.site/32da9811cd284eaab7c3d8390c0ddccc")
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
        self.view = self.settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.configureDelegation()
        self.setupNavigation()
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
            logOut: self.logOutPublisher.eraseToAnyPublisher(),
            signOut: self.signOutPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: SettingViewModel.Output?) {
        guard let output else { return }
        
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
        self.settingView.listTableView.delegate = self
        self.settingView.listTableView.dataSource = self
    }
    
    private func configureNavigation() {
        guard let navigationController = self.navigationController else { return }
        self.settingView.configureNavigationBarTitle(navigationController)
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

extension SettingViewController: MFMailComposeViewControllerDelegate {
    private func sendReportMail() {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            let emailAdress = "foodbowl5502@gmail.com"
            let messageBody = """
                내용을 작성해주세요.
                """
            let nickname = UserDefaultStorage.nickname

            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients([emailAdress])
            composeVC.setSubject("[풋볼] \(nickname)")
            composeVC.setMessageBody(messageBody, isHTML: false)

            present(composeVC, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }

    private func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "메일 전송 실패", message: "이메일 설정을 확인하고 다시 시도해주세요.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default)
        sendMailErrorAlert.addAction(confirmAction)
        present(sendMailErrorAlert, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
