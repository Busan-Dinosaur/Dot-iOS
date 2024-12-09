//
//  PaddingLabel.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/09/15.
//

import UIKit

class PaddingLabel: UILabel {
    var padding: UIEdgeInsets

    @IBInspectable
    var left: CGFloat {
        get {
            padding.left
        }
        set {
            padding.left = newValue
        }
    }

    @IBInspectable
    var right: CGFloat {
        get {
            padding.right
        }
        set {
            padding.right = newValue
        }
    }

    @IBInspectable
    var top: CGFloat {
        get {
            padding.top
        }
        set {
            padding.top = newValue
        }
    }

    @IBInspectable
    var bottom: CGFloat {
        get {
            self.padding.bottom
        }
        set {
            self.padding.bottom = newValue
        }
    }

    override init(frame: CGRect) {
        self.padding = .zero
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        self.padding = .zero
        super.init(coder: coder)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    convenience init(inset: UIEdgeInsets) {
        self.init(frame: .zero)
        self.padding = inset
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += padding.left + padding.right
        size.height += padding.top + padding.bottom
        return size
    }
}
