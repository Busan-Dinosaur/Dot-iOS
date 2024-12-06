//
//  PhotoesSelectView.swift
//  FoodBowl
//
//  Created by Coby on 2/12/24.
//

import Combine
import UIKit

import SnapKit
import Then

final class PhotoesSelectView: UIView, BaseViewType {
    
    private enum Size {
        static let cellWidth: CGFloat = 100
        static let cellHeight: CGFloat = cellWidth
        static let collectionInset = UIEdgeInsets(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
    }
    
    // MARK: - ui component
    
    private let newFeedGuideLabel = PaddingLabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .bold)
        $0.text = "후기 작성"
        $0.textColor = .mainTextColor
        $0.padding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        $0.frame = CGRect(x: 0, y: 0, width: 150, height: 0)
    }
    private let closeButton = UIButton().then {
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.mainColor, for: .normal)
        $0.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline, weight: .regular)
    }
    private let guidePhotoLabel = UILabel().then {
        $0.text = "사진"
        $0.font = UIFont.preferredFont(forTextStyle: .body, weight: .medium)
        $0.textColor = .mainTextColor
    }
    private let guideDetailLabel = UILabel().then {
        $0.text = "음식 사진을 등록하면, 자동으로 해당 가게가 검색됩니다."
        $0.font = UIFont.preferredFont(forTextStyle: .footnote, weight: .regular)
        $0.textColor = .subTextColor
        $0.numberOfLines = 0
    }
    private let collectionViewFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.sectionInset = Size.collectionInset
        $0.itemSize = CGSize(width: Size.cellWidth, height: Size.cellHeight)
        $0.minimumInteritemSpacing = 4
    }
    private lazy var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout).then {
        $0.showsVerticalScrollIndicator = false
        $0.register(PhotoPlusCollectionViewCell.self, forCellWithReuseIdentifier: PhotoPlusCollectionViewCell.className)
        $0.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.className)
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
    }
    private let nextButton = CompleteButton().then {
        $0.label.text = "다음"
        $0.isEnabled = true
    }
    
    // MARK: - property
    
    private var reviewImages = [UIImage]()
    
    var closeButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.closeButton.buttonTapPublisher
    }
    var nextButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.nextButton.buttonTapPublisher
    }
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
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
    
    func configureDelegation(_ delegate: UICollectionViewDataSource) {
        self.listCollectionView.dataSource = delegate
    }
    
    func collectionView() -> UICollectionView {
        return self.listCollectionView
    }
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(
            self.guidePhotoLabel,
            self.guideDetailLabel,
            self.listCollectionView,
            self.nextButton
        )

        self.guidePhotoLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).inset(SizeLiteral.verticalPadding)
            $0.leading.equalToSuperview().inset(SizeLiteral.horizantalPadding)
        }
        
        self.guideDetailLabel.snp.makeConstraints {
            $0.top.equalTo(self.guidePhotoLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
        }
        
        self.listCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.guideDetailLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }

        self.nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
            $0.bottom.equalTo(self.keyboardLayoutGuide.snp.top).offset(-10)
            $0.height.equalTo(60)
        }
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
}
