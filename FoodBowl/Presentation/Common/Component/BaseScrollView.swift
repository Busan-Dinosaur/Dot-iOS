//
//  BaseScrollView.swift
//  FoodBowl
//
//  Created by Coby on 1/24/24.
//

import UIKit

class BaseScrollView<Model>: UIScrollView {
    var model: Model? {
        didSet {
            if let model = model {
                bind(model)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureUI() {}
    func bind(_: Model) {}
}
