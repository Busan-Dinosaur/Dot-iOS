//
//  PhotoCollectionViewCell.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2022/12/23.
//

import UIKit

import SnapKit
import Then

final class PhotoCollectionViewCell: UICollectionViewCell, BaseViewType {
    
    // MARK: - ui component
    
    let imageView = UIImageView().then {
        $0.backgroundColor = .grey002
        $0.contentMode = .scaleAspectFill
    }
    
    // MARK: - property
    
    var cellTapAction: ((PhotoCollectionViewCell) -> Void)?
    
    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupLayout() {
        self.contentView.addSubviews(self.imageView)

        self.imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureUI() {
        self.backgroundColor = .grey002
        self.clipsToBounds = true
        self.makeBorderLayer(color: .grey002)
    }
    
    func setupAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        self.contentView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func cellTapped() {
        self.cellTapAction?(self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
}
