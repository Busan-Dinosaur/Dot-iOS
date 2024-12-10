//
//  PhotoesSelectViewController.swift
//  FoodBowl
//
//  Created by Coby on 2/12/24.
//

import Combine
import UIKit
import MapKit

import SnapKit
import Then

final class PhotoesSelectViewController: UIViewController, PhotoPickerable {
    
    // MARK: - ui component
    
    private let photoesSelectView: PhotoesSelectView = PhotoesSelectView()
    
    // MARK: - property
    
    private let viewModel: any PhotoesSelectViewModelType
    private var cancellable: Set<AnyCancellable> = Set()
    
    private var reviewImages = [UIImage]()
    private var location: CLLocationCoordinate2D? = nil
    
    // MARK: - init
    
    init(viewModel: any PhotoesSelectViewModelType) {
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
        self.view = self.photoesSelectView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDelegation()
        self.configureNavigation()
        self.bindUI()
    }
    
    private func bindUI() {
        self.photoesSelectView.closeButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.makeRequestAlert(
                    title: "후기",
                    message: "후기를 작성하지 않으시나요?",
                    okTitle: "네",
                    cancelTitle: "아니요",
                    okAction: { _ in
                        DispatchQueue.main.async { [weak self] in
                            self?.viewModel.dismiss()
                        }
                    }
                )
            })
            .store(in: &self.cancellable)
        
        self.photoesSelectView.nextButtonDidTapPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                
                if self.reviewImages.isEmpty {
                    self.makeRequestAlert(
                        title: "후기",
                        message: "사진없이 후기를 작성하시나요?",
                        okTitle: "네",
                        cancelTitle: "아니요",
                        okAction: { _ in
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                self.viewModel.presentCreateReviewViewController(
                                    reviewImages: self.reviewImages,
                                    location: self.location
                                )
                            }
                        }
                    )
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.viewModel.presentCreateReviewViewController(
                            reviewImages: self.reviewImages,
                            location: self.location
                        )
                    }
                }
            })
            .store(in: &self.cancellable)
    }
    
    // MARK: - func
    
    private func configureDelegation() {
        self.photoesSelectView.configureDelegation(self)
    }
    
    private func configureNavigation() {
        guard let navigationController = self.navigationController else { return }
        self.photoesSelectView.configureNavigationBarItem(navigationController)
    }
    
    @objc
    private func photoPlusCellDidTap() {
        self.photoesAddButtonDidTap()
    }
    
    func setPhotoes(images: [UIImage], location: CLLocationCoordinate2D?) {
        self.reviewImages = images
        self.location = location
        self.photoesSelectView.collectionView().reloadData()
    }
}

extension PhotoesSelectViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return self.reviewImages.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoPlusCollectionViewCell.className,
                for: indexPath
            ) as? PhotoPlusCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.photoPlusCellDidTap))
            cell.addGestureRecognizer(tapGesture)

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoCollectionViewCell.className,
                for: indexPath
            ) as? PhotoCollectionViewCell else {
                return UICollectionViewCell()
            }

            cell.imageView.image = self.reviewImages[indexPath.item - 1]

            return cell
        }
    }
}
