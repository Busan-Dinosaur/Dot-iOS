//
//  BlameView.swift
//  FoodBowl
//
//  Created by Coby on 12/31/23.
//

import Combine
import UIKit

import SnapKit
import Then

final class BlameView: UIView, BaseViewType {
    
    // MARK: - ui component
    
    private let blameGuideLabel = PaddingLabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .bold)
        $0.text = "신고"
        $0.textColor = .mainTextColor
        $0.padding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        $0.frame = CGRect(x: 0, y: 0, width: 150, height: 0)
    }
    private let closeButton = UIButton().then {
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.mainColor, for: .normal)
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline, weight: .regular)
    }
    private let guideCommentLabel = UILabel().then {
        $0.text = "신고 내용"
        $0.font = UIFont.preferredFont(forTextStyle: .body, weight: .medium)
        $0.textColor = .mainTextColor
    }
    private lazy var commentTextView = UITextView().then {
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .light)
        $0.textAlignment = NSTextAlignment.left
        $0.dataDetectorTypes = UIDataDetectorTypes.all
        $0.text = textViewPlaceHolder
        $0.textColor = .grey001
        $0.isEditable = true
        $0.delegate = self
        $0.isScrollEnabled = true
        $0.showsVerticalScrollIndicator = false
        $0.isUserInteractionEnabled = true
        $0.makeBorderLayer(color: .grey002)
        $0.backgroundColor = .mainBackgroundColor
    }
    private let completeButton = CompleteButton()
    
    // MARK: - property
    
    private let textViewPlaceHolder = "100자 이내"
    var closeButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.closeButton.buttonTapPublisher
    }
    let makeAlertPublisher = PassthroughSubject<String, Never>()
    let completeButtonDidTapPublisher = PassthroughSubject<String, Never>()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
        self.setupAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - func
    
    func configureNavigationBarItem(_ navigationController: UINavigationController) {
        let navigationItem = navigationController.topViewController?.navigationItem
        let blameGuideLabel = navigationController.makeBarButtonItem(with: blameGuideLabel)
        let closeButton = navigationController.makeBarButtonItem(with: closeButton)
        navigationItem?.leftBarButtonItem = blameGuideLabel
        navigationItem?.rightBarButtonItem = closeButton
    }
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(
            self.guideCommentLabel,
            self.commentTextView,
            self.completeButton
        )

        self.guideCommentLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
        }

        self.commentTextView.snp.makeConstraints {
            $0.top.equalTo(self.guideCommentLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.height.equalTo(100)
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
            guard let self = self,
                  let comment = self.commentTextView.text,
                  self.completeButton.isEnabled
            else { return }
            self.completeButtonDidTapPublisher.send(comment)
        }
        self.completeButton.addAction(completeAction, for: .touchUpInside)
    }
}

extension BlameView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let newText = currentText.replacingCharacters(in: range, with: text)
        let numberOfLines = newText.components(separatedBy: "\n").count
        
        self.completeButton.isEnabled = newText.count != 0 && newText != self.textViewPlaceHolder
        
        if newText.count > 100 {
            self.makeAlertPublisher.send("100자 이하로 작성해주세요.")
            return false
        }
        
        if numberOfLines > 5 {
            self.makeAlertPublisher.send("5번 이내로 줄바꿈이 가능해요.")
            return false
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == self.textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .mainTextColor
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = self.textViewPlaceHolder
            textView.textColor = .grey001
        }
    }
}
