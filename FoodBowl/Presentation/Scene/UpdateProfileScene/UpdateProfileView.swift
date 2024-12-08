//
//  UpdateProfileView.swift
//  FoodBowl
//
//  Created by Coby on 1/21/24.
//

import Combine
import UIKit

import Kingfisher
import SnapKit
import Then

final class UpdateProfileView: UIView, BaseViewType {
    
    // MARK: - ui component
    
    private let scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.showsVerticalScrollIndicator = false
    }
    private let contentView = UIView()
    let profileImageButton = UIButton().then {
        $0.backgroundColor = .grey003
        $0.layer.cornerRadius = 50
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.grey002.cgColor
        $0.layer.borderWidth = 1
        $0.setImage(ImageLiteral.defaultProfile, for: .normal)
    }
    
    private let nicknameLabel = UILabel().then {
        $0.text = "닉네임"
        $0.font = UIFont.preferredFont(forTextStyle: .body, weight: .medium)
        $0.textColor = .mainTextColor
    }
    private lazy var nicknameField = UITextField().then {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.grey001,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline, weight: .regular)
        ]
        $0.backgroundColor = .mainBackgroundColor
        $0.attributedPlaceholder = NSAttributedString(string: "10자 이내", attributes: attributes)
        $0.autocapitalizationType = .none
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        $0.leftViewMode = .always
        $0.clearButtonMode = .always
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .regular)
        $0.textColor = .mainTextColor
        $0.makeBorderLayer(color: .grey002)
        $0.delegate = self
        $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    private let introductionLabel = UILabel().then {
        $0.text = "한줄 소개"
        $0.font = UIFont.preferredFont(forTextStyle: .body, weight: .medium)
        $0.textColor = .mainTextColor
    }
    private lazy var introductionField = UITextField().then {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.grey001,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline, weight: .regular)
        ]
        $0.backgroundColor = .mainBackgroundColor
        $0.attributedPlaceholder = NSAttributedString(string: "20자 이내", attributes: attributes)
        $0.autocapitalizationType = .none
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        $0.leftViewMode = .always
        $0.clearButtonMode = .always
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .regular)
        $0.textColor = .mainTextColor
        $0.makeBorderLayer(color: .grey002)
        $0.delegate = self
        $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    private let completeButton = CompleteButton()
    
    // MARK: - property
    
    var profileImageButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.profileImageButton.buttonTapPublisher
    }
    let makeAlertPublisher = PassthroughSubject<String, Never>()
    let completeButtonDidTapPublisher = PassthroughSubject<(String, String), Never>()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
        self.setupAction()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - func
    
    func configureNavigationBarTitle(_ navigationController: UINavigationController) {
        let navigationItem = navigationController.topViewController?.navigationItem
        navigationItem?.title = "프로필 수정"
    }
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(
            self.scrollView,
            self.completeButton
        )
        
        self.scrollView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(self.completeButton.snp.top).offset(-20)
            $0.leading.trailing.equalToSuperview()
        }
        
        self.scrollView.addSubview(self.contentView)
        
        self.contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        self.contentView.addSubviews(
            self.profileImageButton,
            self.nicknameLabel,
            self.nicknameField,
            self.introductionLabel,
            self.introductionField
        )

        self.profileImageButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(100)
        }

        self.nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(self.profileImageButton.snp.bottom).offset(40)
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
        }

        self.nicknameField.snp.makeConstraints {
            $0.top.equalTo(self.nicknameLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.height.equalTo(50)
        }

        self.introductionLabel.snp.makeConstraints {
            $0.top.equalTo(self.nicknameField.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
        }

        self.introductionField.snp.makeConstraints {
            $0.top.equalTo(self.introductionLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview()
        }

        self.completeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.bottom.equalTo(self.keyboardLayoutGuide.snp.top).offset(-10)
            $0.height.equalTo(60)
        }
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
    
    // MARK: - Private - func

    private func setupAction() {
        let completeAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            guard let nickname = self.nicknameField.text,
                  self.completeButton.isEnabled
            else { return }
            self.completeButtonDidTapPublisher.send((nickname, self.introductionField.text ?? ""))
        }
        self.completeButton.addAction(completeAction, for: .touchUpInside)
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        self.completeButton.isEnabled = !(self.nicknameField.text?.isEmpty ?? true)
    }
}

extension UpdateProfileView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        var maxLength: Int {
            switch textField {
            case nicknameField:
                return 10
            default:
                return 20
            }
        }
        
        if updatedText.count > maxLength {
            self.makeAlertPublisher.send("\(maxLength)자 이하로 작성해주세요.")
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UpdateProfileView {
    func configureView(member: Member) {
        if let profileImageUrl = member.profileImageUrl,
           let url = URL(string: profileImageUrl) {
            self.profileImageButton.kf.setImage(with: url, for: .normal)
        }
        
        self.nicknameField.text = member.nickname
        self.introductionField.text = member.introduction
        self.completeButton.isEnabled = member.nickname.count != 0
    }
}
