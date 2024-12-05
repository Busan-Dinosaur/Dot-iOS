//
//  ModalView.swift
//  FoodBowl
//
//  Created by Coby on 12/5/24.
//

import UIKit

import SnapKit
import Then

class ModalView: UIView, UIGestureRecognizerDelegate {

    var didChangeState: ((Int) -> Void)?
    private var snapTopConstraint: SnapKit.Constraint?
    private var states: [CGFloat] = []
    private var currentStateIndex = 0
    private var isDraggingModal = false

    private let grabBar = UIView().then {
        $0.backgroundColor = UIColor.lightGray
        $0.layer.cornerRadius = 3
    }

    private let containerView = UIView()
    private weak var scrollView: UIScrollView?

    init(states: [CGFloat]) {
        super.init(frame: .zero)
        self.states = states
        self.setupView()
        self.setupDragGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        self.backgroundColor = .mainBackgroundColor
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true

        // Add grab bar
        self.addSubview(self.grabBar)
        self.grabBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(6)
        }

        // Add container view
        self.addSubview(self.containerView)
        self.containerView.snp.makeConstraints {
            $0.top.equalTo(self.grabBar.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    func attach(to superview: UIView, initialStateIndex: Int) {
        guard initialStateIndex < self.states.count else { return }

        superview.addSubview(self)
        self.currentStateIndex = initialStateIndex

        self.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            self.snapTopConstraint = $0.top.equalTo(superview.snp.bottom).offset(-self.states[initialStateIndex]).constraint
        }
    }

    func setContentView(_ view: UIView) {
        self.containerView.addSubview(view)
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // If the content view is a UIScrollView, keep a reference to it
        if let scrollView = view as? UIScrollView {
            self.scrollView = scrollView
        }
    }

    private func setupDragGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDrag(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
    }

    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        guard let superview = self.superview else { return }

        let translation = gesture.translation(in: superview)
        let velocity = gesture.velocity(in: superview)

        switch gesture.state {
        case .changed:
            if let scrollView = self.scrollView {
                let isAtTop = scrollView.contentOffset.y <= 0
                let isAtBottom = scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.height

                if (isAtTop && velocity.y > 0) || (isAtBottom && velocity.y < 0) {
                    self.isDraggingModal = true
                    scrollView.contentOffset = .zero // Freeze scrollView while dragging modal
                } else {
                    self.isDraggingModal = false
                }
            } else {
                self.isDraggingModal = true
            }

            if self.isDraggingModal, let currentTopConstraint = self.snapTopConstraint {
                let newTopConstant = currentTopConstraint.layoutConstraints.first!.constant + translation.y
                if newTopConstant <= -self.states[0] && newTopConstant >= -self.states[self.states.count - 1] {
                    currentTopConstraint.update(offset: newTopConstant)
                    gesture.setTranslation(.zero, in: superview)
                }
            }
        case .ended:
            if self.isDraggingModal, let currentTopConstraint = self.snapTopConstraint {
                let targetStateIndex = self.closestStateIndex(to: currentTopConstraint.layoutConstraints.first!.constant)
                self.currentStateIndex = targetStateIndex
                let targetConstant = -self.states[targetStateIndex]
                self.animate(to: targetConstant)
                self.didChangeState?(self.currentStateIndex)
            }
        default:
            break
        }
    }

    private func closestStateIndex(to constant: CGFloat) -> Int {
        let targetConstant = -constant
        var closestIndex = 0
        var minDistance = abs(self.states[0] - targetConstant)

        for i in 1..<self.states.count {
            let distance = abs(self.states[i] - targetConstant)
            if distance < minDistance {
                minDistance = distance
                closestIndex = i
            }
        }
        return closestIndex
    }

    private func animate(to targetConstant: CGFloat) {
        UIView.animate(withDuration: 0.3, animations: {
            self.snapTopConstraint?.update(offset: targetConstant)
            self.superview?.layoutIfNeeded()
        })
    }

    // UIGestureRecognizerDelegate method to allow simultaneous gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}