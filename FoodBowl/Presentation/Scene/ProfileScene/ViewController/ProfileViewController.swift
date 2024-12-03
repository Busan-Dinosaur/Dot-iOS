//
//  ProfileViewController.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import Combine
import UIKit

import SnapKit
import Then

final class ProfileViewController: OriginalMapViewController {
    
    // MARK: - ui component
    
    private let userNicknameLabel = PaddingLabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .bold)
        $0.text = "그냥저냥"
        $0.textColor = .mainTextColor
        $0.padding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        $0.frame = CGRect(x: 0, y: 0, width: 200, height: 0)
    }
    private let optionButton = OptionButton()
    private let settingButton = SettingButton()
    private let profileHeaderView = ProfileHeaderView()
    
    // MARK: - property
    
    private let viewWillAppearPublisher: PassthroughSubject<Void, Never> = PassthroughSubject()
    private let removeButtonDidTapPublisher = PassthroughSubject<Int, Never>()

    override func setupLayout() {
        super.setupLayout()
        self.categoryListView.removeFromSuperview()
        self.view.addSubviews(
            self.profileHeaderView,
            self.categoryListView
        )

        self.profileHeaderView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }

        self.categoryListView.snp.makeConstraints {
            $0.top.equalTo(self.profileHeaderView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }

        self.trackingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(self.categoryListView.snp.bottom).offset(20)
            $0.height.width.equalTo(40)
        }
    }
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emptyView.findButton.isHidden = !self.isOwn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewWillAppearPublisher.send(())
    }
    
    // MARK: - func - bind
    
    override func bindViewModel() {
        let output = self.transformedOutput()
        self.configureNavigation()
        self.bindOutputToViewModel(output)
    }
    
    private func transformedOutput() -> ProfileViewModel.Output? {
        guard let viewModel = self.viewModel as? ProfileViewModel else { return nil }
        let input = ProfileViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            viewWillAppear: self.viewWillAppearPublisher.eraseToAnyPublisher(),
            setCategory: self.categoryListView.setCategoryPublisher.eraseToAnyPublisher(),
            followMember: self.followButtonDidTapPublisher.eraseToAnyPublisher(),
            customLocation: self.locationPublisher.eraseToAnyPublisher(),
            bookmarkButtonDidTap: self.bookmarkButtonDidTapPublisher.eraseToAnyPublisher(),
            removeButtonDidTap: self.removeButtonDidTapPublisher.eraseToAnyPublisher(),
            scrolledToBottom: self.feedListView.collectionView().scrolledToBottomPublisher.eraseToAnyPublisher(),
            refreshControl: self.feedListView.refreshPublisher.eraseToAnyPublisher()
        )
        return viewModel.transform(from: input)
    }
    
    private func bindOutputToViewModel(_ output: ProfileViewModel.Output?) {
        guard let output else { return }
        
        output.member
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let member):
                    self?.setUpProfileHeader(member: member)
                    AppStoreReviewManager.requestReviewIfAppropriate()
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.followMember
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success:
                    self?.profileHeaderView.followButton.isSelected.toggle()
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.stores
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let stores):
                    self?.setupMarkers(stores)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.reviews
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let reviews):
                    self?.loadReviews(reviews)
                    self?.feedListView.refreshControl().endRefreshing()
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.moreReviews
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let reviews):
                    self?.loadMoreReviews(reviews)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.isBookmarked
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let storeId):
                    self?.updateBookmark(storeId)
                case .failure(let error):
                    self?.makeErrorAlert(
                        title: "에러",
                        error: error
                    )
                }
            })
            .store(in: &self.cancellable)
        
        output.isRemoved
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let reviewId):
                    self?.deleteReview(reviewId)
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
    
    private func configureNavigation() {
        if isOwn {
            let userNicknameLabel = self.makeBarButtonItem(with: self.userNicknameLabel)
            let plusButton = self.makeBarButtonItem(with: self.plusButton)
            let settingButton = self.makeBarButtonItem(with: self.settingButton)
            self.navigationItem.leftBarButtonItem = userNicknameLabel
            self.navigationItem.rightBarButtonItems = [settingButton, plusButton]
            self.profileHeaderView.followButton.isHidden = true
        }
    }
    
    override func configureModal() {
        super.configureModal()
        self.modalMaxHeight -= 100
    }
    
    override func setupAction() {
        super.setupAction()
        
        let optionButtonAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            guard let viewModel = self.viewModel as? ProfileViewModel else { return }
            self.presentMemberOptionAlert(memberId: viewModel.memberId)
        }
        self.optionButton.addAction(optionButtonAction, for: .touchUpInside)
        
        let settingButtonAction = UIAction { [weak self] _ in
            self?.presentSettingViewController()
        }
        self.settingButton.addAction(settingButtonAction, for: .touchUpInside)
        
        let followerAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            guard let viewModel = self.viewModel as? ProfileViewModel else { return }
            self.presentFollowerViewController(id: viewModel.memberId, isOwn: self.isOwn)
        }
        let followingAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            guard let viewModel = self.viewModel as? ProfileViewModel else { return }
            self.presentFollowingViewController(id: viewModel.memberId, isOwn: self.isOwn)
        }
        let followButtonAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            guard let viewModel = self.viewModel as? ProfileViewModel else { return }
            self.followButtonDidTapPublisher.send((viewModel.memberId, self.profileHeaderView.followButton.isSelected))
        }
        let editButtonAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.presentUpdateProfileViewController()
        }
        self.profileHeaderView.followerInfoButton.addAction(followerAction, for: .touchUpInside)
        self.profileHeaderView.followingInfoButton.addAction(followingAction, for: .touchUpInside)
        self.profileHeaderView.followButton.addAction(followButtonAction, for: .touchUpInside)
        self.profileHeaderView.editButton.addAction(editButtonAction, for: .touchUpInside)
    }
    
    private func setUpProfileHeader(member: Member) {
        if let url = member.profileImageUrl {
            self.profileHeaderView.userImageView.kf.setImage(with: URL(string: url))
        } else {
            self.profileHeaderView.userImageView.image = ImageLiteral.defaultProfile
        }
        
        self.userNicknameLabel.text = member.nickname
        self.profileHeaderView.userInfoLabel.text = member.introduction == "" ? "소개를 작성하지 않았어요." : member.introduction
        self.profileHeaderView.followerInfoButton.numberLabel.text = "\(member.followerCount)명"
        self.profileHeaderView.followingInfoButton.numberLabel.text = "\(member.followingCount)명"
        self.profileHeaderView.followButton.isSelected = member.isFollowing
        self.profileHeaderView.followButton.isHidden = member.isMyProfile
        self.profileHeaderView.editButton.isHidden = !isOwn
        
        if !member.isMyProfile {
            let optionButton = self.makeBarButtonItem(with: self.optionButton)
            self.navigationItem.rightBarButtonItem = optionButton
        }
        
        if !isOwn {
            self.title = member.nickname
        }
    }
    
    override func updateReview(reviewId: Int) {
        self.presentUpdateReviewViewController(id: reviewId)
    }
    
    override func removeReview(reviewId: Int) {
        self.removeButtonDidTapPublisher.send(reviewId)
    }
}
