//
//  PhotoPlusCollectionViewCell.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/16.
//

import UIKit

import SnapKit
import Then

final class PhotoPlusCollectionViewCell: UICollectionViewCell, BaseViewType {
    
    // MARK: - ui component
    
    private let plusImageView = UIImageView().then {
        $0.image = ImageLiteral.camera.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .grey001
        $0.contentMode = .scaleAspectFill
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

    func setupLayout() {
        self.contentView.addSubviews(self.plusImageView)

        self.plusImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(30)
        }
    }

    func configureUI() {
        self.backgroundColor = .grey002
        self.clipsToBounds = true
        self.makeBorderLayer(color: .grey002)
    }
}
