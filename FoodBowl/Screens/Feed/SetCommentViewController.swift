//
//  SetCommentViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import UIKit

import SnapKit
import Then

final class SetCommentViewController: BaseViewController {
    var delegate: SetCommentViewControllerDelegate?

    private enum Size {
        static let cellWidth: CGFloat = 100
        static let cellHeight: CGFloat = cellWidth
        static let collectionInset = UIEdgeInsets(top: 0,
                                                  left: 20,
                                                  bottom: 0,
                                                  right: 20)
    }

    private var selectedImages = [UIImage]()

    private let textViewPlaceHolder = "텍스트를 입력하세요."

    // MARK: - property

    private let guideLabel = UILabel().then {
        $0.text = "후기를 작성해주세요."
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .medium)
    }

    private let collectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.sectionInset = Size.collectionInset
        $0.itemSize = CGSize(width: Size.cellWidth, height: Size.cellHeight)
        $0.minimumInteritemSpacing = 4
    }

    private lazy var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout).then {
        $0.dataSource = self
        $0.delegate = self
        $0.showsVerticalScrollIndicator = false
        $0.register(FeedThumnailCollectionViewCell.self, forCellWithReuseIdentifier: FeedThumnailCollectionViewCell.className)
    }

    lazy var commentTextView = UITextView().then {
        $0.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .light)
        $0.textAlignment = NSTextAlignment.left
        $0.dataDetectorTypes = UIDataDetectorTypes.all
        $0.text = textViewPlaceHolder
        $0.textColor = .grey001
        $0.isEditable = true
        $0.delegate = self
        $0.isScrollEnabled = true
        $0.isUserInteractionEnabled = true
    }

    // MARK: - life cycle

    override func render() {
        view.addSubviews(guideLabel, commentTextView)

        guideLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
            $0.leading.equalToSuperview().inset(20)
        }

        commentTextView.snp.makeConstraints {
            $0.top.equalTo(guideLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-40)
        }
    }
}

extension SetCommentViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .grey001
        }
    }
}

extension SetCommentViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return selectedImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedThumnailCollectionViewCell.className, for: indexPath) as? FeedThumnailCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.thumnailImageView.image = selectedImages[indexPath.item]

        return cell
    }
}

protocol SetCommentViewControllerDelegate: AnyObject {
    func setComment(comment: String?)
}
