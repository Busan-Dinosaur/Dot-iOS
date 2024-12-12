//
//  MapItem.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/01/28.
//

import UIKit

import MapKit
import Then

final class MapItemAnnotationView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let marker = newValue as? Marker else { return }
            let feedButton = FeedButton().then {
                let action = UIAction { _ in marker.handler() }
                $0.addAction(action, for: .touchUpInside)
            }
            clusteringIdentifier = "MapItem"
            rightCalloutAccessoryView = feedButton
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: 5)
            markerTintColor = UIColor.mainColor
            glyphImage = marker.glyphImage
        }
    }
}

final class ClusterAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            guard let cluster = annotation as? MKClusterAnnotation else { return }
            displayPriority = .defaultHigh

            let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
            image = UIGraphicsImageRenderer.image(for: cluster.memberAnnotations, in: rect)
        }
    }
}

extension UIGraphicsImageRenderer {
    static func image(for annotations: [MKAnnotation], in rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: rect.size)

        let totalCount = annotations.count
        let countText = "\(totalCount)"

        return renderer.image { _ in
            UIColor.mainColor.setFill()
            UIBezierPath(ovalIn: rect).fill()

            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 24, height: 24)).fill()

            countText.drawForCluster(in: rect)
        }
    }
}
