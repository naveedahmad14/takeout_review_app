//
//  LocationService.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 26/03/2025.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    let manager = CLLocationManager()

    func requestLocation() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
}
