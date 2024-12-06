//
//  UpdateReviewView.swift
//  FoodBowl
//
//  Updated by Coby on 1/23/24.
//

import Combine
import UIKit

import SnapKit
import Then

final class UpdateReviewView: UIView, BaseViewType {
    
    // MARK: - ui component
    
    private let scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.showsVerticalScrollIndicator = false
    }
    private let contentView = UIView()
    private let newFeedGuideLabel = PaddingLabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .bold)
        $0.text = "후기 수정"
        $0.textColor = .mainTextColor
        $0.padding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        $0.frame = CGRect(x: 0, y: 0, width: 150, height: 0)
    }
    private let closeButton = UIButton().then {
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.mainColor, for: .normal)
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline, weight: .regular)
    }
    let selectedStoreView = SelectedStoreView()
    private let guideCommentLabel = UILabel().then {
        $0.text = "한줄평"
        $0.font = UIFont.preferredFont(forTextStyle: .body, weight: .medium)
        $0.textColor = .mainTextColor
    }
    private lazy var commentTextView = UITextView().then {
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .light)
        $0.textAlignment = NSTextAlignment.left
        $0.dataDetectorTypes = UIDataDetectorTypes.all
        $0.text = textViewStoreHolder
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
    
    private let textViewStoreHolder = "100자 이내"
    
    var closeButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.closeButton.buttonTapPublisher
    }
    let makeAlertPublisher = PassthroughSubject<String, Never>()
    let showStorePublisher = PassthroughSubject<String, Never>()
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
        let newFeedGuideLabel = navigationController.makeBarButtonItem(with: newFeedGuideLabel)
        let closeButton = navigationController.makeBarButtonItem(with: closeButton)
        navigationItem?.leftBarButtonItem = newFeedGuideLabel
        navigationItem?.rightBarButtonItem = closeButton
    }
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(self.scrollView, self.completeButton)
        
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
            self.selectedStoreView,
            self.guideCommentLabel,
            self.commentTextView
        )

        self.selectedStoreView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.height.equalTo(60)
        }

        self.guideCommentLabel.snp.makeConstraints {
            $0.top.equalTo(self.selectedStoreView.snp.bottom).offset(30)
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
        }

        self.commentTextView.snp.makeConstraints {
            $0.top.equalTo(self.guideCommentLabel.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
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

extension UpdateReviewView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text as NSString
        let newText = currentText.replacingCharacters(in: range, with: text)
        let numberOfLines = newText.components(separatedBy: "\n").count
        
        self.completeButton.isEnabled = !self.selectedStoreView.isHidden && newText.count != 0 && newText != self.textViewStoreHolder
        
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
        if textView.text == self.textViewStoreHolder {
            textView.text = nil
            textView.textColor = .mainTextColor
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = self.textViewStoreHolder
            textView.textColor = .grey001
        }
    }
}

extension UpdateReviewView {
    func configureReview(_ review: Review) {
        self.selectedStoreView.mapButton.isHidden = true
        self.selectedStoreView.configureStore(review.store)
        self.commentTextView.text = review.comment.content
        self.commentTextView.textColor = .mainTextColor
    }
}
