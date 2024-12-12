//
//  LocationManager.swift
//  FoodBowl
//
//  Created by COBY_PRO on 2023/02/04.
//

import CoreLocation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    let manager = CLLocationManager()

    private override init() {}

    func checkLocationService() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.setupLocationManager()
                self.checkLocationManagerAuthorization()
            } else {
                self.setupNotificationCenter(object: ["error": true])
            }
        }
    }

    func setupLocationManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func checkLocationManagerAuthorization() {
        switch authorizationStatus() {
        case .notDetermined:
            print("Auth: notDetermined")
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            print("Auth: authorizedWhenInUse")
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Auth: denied")
            setupLocationSetting()
            setupNotificationCenter(object: ["error": true])
        default:
            setupLocationSetting()
            setupNotificationCenter(object: ["error": true])
        }
    }

    func authorizationStatus() -> CLAuthorizationStatus {
        let status: CLAuthorizationStatus = CLLocationManager().authorizationStatus
        return status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let object: [String: Any] = [
                "error": false,
                "location": location
            ]
            DispatchQueue.main.async {
                self.setupNotificationCenter(object: object)
            }
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationService()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
    }

    func setupNotificationCenter(object: Any? = nil) {
        NotificationCenter.default.post(name: .sharedLocation, object: object)
    }

    func setupLocationSetting() {
        var locationAlert: UIAlertController {
            let alert = UIAlertController(title: "위치 정보를 허용하시겠습니까?", message: "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "취소", style: .cancel)

            let action = UIAlertAction(title: "설정", style: .default) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                }
            }

            alert.addAction(cancel)
            alert.addAction(action)

            return alert
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            guard let rootVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController
            else { return }

            rootVC.present(locationAlert, animated: true, completion: nil)
        }
    }
}
