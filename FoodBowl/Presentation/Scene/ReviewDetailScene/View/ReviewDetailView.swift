//
//  ReviewDetailView.swift
//  FoodBowl
//
//  Created by Coby on 1/24/24.
//

import Combine
import UIKit

import Kingfisher
import SnapKit
import Then

final class ReviewDetailView: UIView, BaseViewType {
    
    // MARK: - ui component
    
    private let scrollView = UIScrollView().then {
        $0.isScrollEnabled = true
        $0.showsVerticalScrollIndicator = false
    }
    private let contentView = UIView()
    private let userInfoButton: UserInfoButton = UserInfoButton()
    private let reviewImagesView = HorizontalScrollView(
        horizontalWidth: UIScreen.main.bounds.size.width,
        horizontalHeight: UIScreen.main.bounds.size.width
    )
    let storeInfoButton: StoreDetailInfoButton = StoreDetailInfoButton()
    private let commentLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .light)
        $0.textColor = .mainTextColor
        $0.numberOfLines = 0
    }
    
    // MARK: - property
    
    var userInfoButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.userInfoButton.buttonTapPublisher
    }
    var storeInfoButtonDidTapPublisher: AnyPublisher<Void, Never> {
        return self.storeInfoButton.buttonTapPublisher
    }
    let bookmarkButtonDidTapPublisher = PassthroughSubject<Bool, Never>()
    
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
    
    func configureNavigationBarTitle(_ navigationController: UINavigationController) {
        let navigationItem = navigationController.topViewController?.navigationItem
        navigationItem?.title = "후기"
    }
    
    // MARK: - base func
    
    func setupLayout() {
        self.addSubviews(self.scrollView)
        
        self.scrollView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        self.scrollView.addSubview(self.contentView)
        
        self.contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        self.contentView.addSubviews(
            self.userInfoButton,
            self.reviewImagesView,
            self.storeInfoButton,
            self.commentLabel
        )
        
        self.userInfoButton.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        self.reviewImagesView.snp.makeConstraints {
            $0.top.equalTo(self.userInfoButton.snp.bottom)
            $0.width.height.equalTo(UIScreen.main.bounds.size.width)
        }
        
        self.storeInfoButton.snp.makeConstraints {
            $0.top.equalTo(self.reviewImagesView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        self.commentLabel.snp.makeConstraints {
            $0.top.equalTo(self.storeInfoButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(SizeLiteral.horizantalPadding)
        }
    }
    
    func configureUI() {
        self.backgroundColor = .mainBackgroundColor
    }
    
    // MARK: - Private - func

    private func setupAction() {
        let bookmarkAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.bookmarkButtonDidTapPublisher.send(self.storeInfoButton.bookmarkButton.isSelected)
        }
        self.storeInfoButton.bookmarkButton.addAction(bookmarkAction, for: .touchUpInside)
    }
}

extension ReviewDetailView {
    func configureReview(_ review: Review) {
        self.userInfoButton.configureUser(review.member)
        self.commentLabel.text = review.comment.content
        self.storeInfoButton.configureStore(review.store)
        self.downloadImages(from: review.comment.imagePaths) { images in
            self.reviewImagesView.model = images
        }
    }
    
    func downloadImages(from urls: [String], completion: @escaping ([UIImage]) -> Void) {
        var images: [UIImage] = []
        let group = DispatchGroup()
        
        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }
            
            group.enter()
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let imageResult):
                    images.append(imageResult.image)
                case .failure(let error):
                    print("Error downloading image: \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(images)
        }
    }
}