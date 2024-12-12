//
//  UIScrollView+Combine.swift
//  FoodBowl
//
//  Created by COBY_PRO on 10/20/23.
//

import Combine
import UIKit

enum ScrollViewEvent {
    case didScroll(scrollView: UIScrollView)
}

extension UIScrollView {
    func eventPublisher(for event: ScrollViewEvent) -> EventPublisher {
        return EventPublisher(scrollView: self)
    }

    struct EventPublisher: Publisher {
        typealias Output = ScrollViewEvent
        typealias Failure = Never

        let scrollView: UIScrollView

        func receive<S>(subscriber: S)
        where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = EventSubscription<S>(target: subscriber)
            subscriber.receive(subscription: subscription)
            scrollView.delegate = subscription
        }
    }

    final class EventSubscription<Target: Subscriber>: NSObject, UIScrollViewDelegate, Subscription
    where Target.Input == ScrollViewEvent {

        var target: Target?

        init(target: Target) {
            self.target = target
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            target = nil
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            _ = target?.receive(.didScroll(scrollView: scrollView))
        }
    }
}

extension UIScrollView {
    var scrollPublisher: AnyPublisher<Void, Never> {
        eventPublisher(for: .didScroll(scrollView: self))
            .map { _ in Void() }
            .eraseToAnyPublisher()
    }
}

extension UIScrollView {    
    var scrolledToBottomPublisher: AnyPublisher<Void, Never> {
        return Publishers
            .CombineLatest3(
                self.publisher(for: \.contentOffset),
                self.publisher(for: \.bounds),
                self.publisher(for: \.contentSize)
            )
            .map { [weak self] (contentOffset, bounds, contentSize) -> Bool in
                guard self != nil else { return false }
                let offsetY = contentOffset.y
                let scrollViewHeight = bounds.size.height
                let contentHeight = contentSize.height
                
                return offsetY > 0 && offsetY + scrollViewHeight >= contentHeight
            }
            .removeDuplicates() // 중복 값을 방지하기 위해
            .filter { $0 } // true일 때만 통과
            .map { _ in () } // Void로 변환
            .eraseToAnyPublisher()
    }
}


