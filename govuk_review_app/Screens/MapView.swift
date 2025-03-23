//
//  MapView.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 17/03/2025.
//

import SwiftUI
import GoogleMaps

struct MapView: UIViewRepresentable {
    var takeouts: [Takeout]

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 53.4832662, longitude: -2.2414207, zoom: 12)
        let mapView = GMSMapView(frame: .zero, camera: camera)

//        for takeout in takeouts {
//            if let latitude = takeout.latitude, let longitude = takeout.longitude {
//                let marker = GMSMarker()
//                marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                marker.title = takeout.name
//                marker.map = mapView
//            }
//        }
//        return mapView
        // Use mock locations if real ones are missing
        let mockLocations = [
            (name: "Mock Takeout 1", lat: 53.4808, lon: -2.2426),
            (name: "Mock Takeout 2", lat: 53.4820, lon: -2.2430),
            (name: "Mock Takeout 3", lat: 53.4850, lon: -2.2400)
        ]

        for location in mockLocations {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
            marker.title = location.name
            marker.map = mapView
        }

        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.clear()

//        for takeout in takeouts {
//            if let latitude = takeout.latitude, let longitude = takeout.longitude {
//                let marker = GMSMarker()
//                marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                marker.title = takeout.name
//                marker.map = uiView
//            }
//        }

        let mockLocations = [
            (name: "Mock Takeout 1", lat: 53.4808, lon: -2.2426),
            (name: "Mock Takeout 2", lat: 53.4820, lon: -2.2430),
            (name: "Mock Takeout 3", lat: 53.4850, lon: -2.2400)
        ]

        for location in mockLocations {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
            marker.title = location.name
            marker.map = uiView
        }
    }
}
