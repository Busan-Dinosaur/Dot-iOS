//
//  SettingViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/26.
//

import MessageUI
import UIKit

import SnapKit
import Then

final class SettingViewController: UIViewController, Navigationable {
    
    // MARK: - ui component
    
    private let settingView: SettingView = SettingView()
    
    // MARK: - property
    
    private var options: [Option] {
        [
            Option(
                title: "공지사항",
                handler: { [weak self] in
                    self?.presentWebViewController(url: "https://coby5502.notion.site/a25fe63009d24b958fe77ab87e53994e")
                }
            ),
            Option(
                title: "개인정보처리방침",
                handler: { [weak self] in
                    self?.presentWebViewController(url: "https://coby5502.notion.site/2ca079dd7b354cd790b3280728ebb0d5")
                }
            ),
            Option(
                title: "이용약관",
                handler: { [weak self] in
                    self?.presentWebViewController(url: "https://coby5502.notion.site/32da9811cd284eaab7c3d8390c0ddccc")
                }
            ),
            Option(
                title: "로그아웃",
                handler: { [weak self] in
                    self?.makeRequestAlert(
                        title: "로그아웃 하시겠어요?",
                        message: "",
                        okTitle: "네",
                        cancelTitle: "아니오",
                        okAction: { _ in
                            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
                            sceneDelegate.logOut()
                        }
                    )
                }
            ),
            Option(
                title: "탈퇴하기",
                handler: { [weak self] in
                    self?.makeRequestAlert(
                        title: "정말 탈퇴하시나요?",
                        message: "",
                        okTitle: "네",
                        cancelTitle: "아니오",
                        okAction: { _ in
                        }
                    )
                }
            ),
        ]
    }
    
    // MARK: - init
    
    deinit {
        print("\(#file) is dead")
    }
    
    // MARK: - life cycle
    
    override func loadView() {
        self.view = self.settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDelegation()
        self.setupNavigation()
        self.configureNavigation()
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

// MARK: - Helper
extension SettingViewController {
    private func presentWebViewController(url: String) {
        let showWebViewController = ShowWebViewController(url: url)
        let navigationController = UINavigationController(rootViewController: showWebViewController)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(navigationController, animated: true)
        }
    }
}