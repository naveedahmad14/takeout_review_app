//
//  MapView.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 17/03/2025.
//

import SwiftUI
import GoogleMaps

struct MapView: UIViewRepresentable {
    var takeouts: [TakeoutEntity]
    var selectedOffice: String

    // Office locations with their coordinates and default zoom levels
    private let officeLocations: [String: (latitude: Double, longitude: Double, zoom: Float)] = [
        "London": (51.514466679975286, -0.07289043154882537, 14.25),
        "Manchester": (53.478221, -2.242756, 14),
        "Bristol": (51.454514, -2.587910, 14)
    ]

    func makeUIView(context: Context) -> GMSMapView {
        // Get the office location or use a default
        let (initialLatitude, initialLongitude, initialZoom) = officeLocations[selectedOffice] ?? (53.4832662, -2.2414207, 12)

        let camera = GMSCameraPosition.camera(withLatitude: initialLatitude, longitude: initialLongitude, zoom: initialZoom)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.delegate = context.coordinator

        // Add markers for takeouts in the selected office
        for takeout in takeouts {
            // Skip takeouts with zero or invalid coordinates or not matching the office
            guard takeout.latitude != 0 && takeout.longitude != 0,
                  let name = takeout.name,
                  takeout.office == selectedOffice else {
                continue
            }

            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: takeout.latitude, longitude: takeout.longitude)
            marker.title = name
            marker.snippet = takeout.tagline
            marker.userData = takeout // Store the entire takeout for later use
            marker.map = mapView
        }

        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Get the office location or use a default
        let (initialLatitude, initialLongitude, initialZoom) = officeLocations[selectedOffice] ?? (53.4832662, -2.2414207, 12)

        // Update camera position
        let camera = GMSCameraPosition.camera(withLatitude: initialLatitude, longitude: initialLongitude, zoom: initialZoom)
        uiView.camera = camera

        // Clear existing markers and re-add them
        uiView.clear()

        // Add markers for takeouts in the selected office
        for takeout in takeouts {
            // Skip takeouts with zero or invalid coordinates or not matching the office
            guard takeout.latitude != 0 && takeout.longitude != 0,
                  let name = takeout.name,
                  takeout.office == selectedOffice else {
                continue
            }

            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: takeout.latitude, longitude: takeout.longitude)
            marker.title = name
            marker.snippet = takeout.tagline
            marker.userData = takeout
            marker.map = uiView
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            // Check if the marker has associated takeout data
            guard let takeout = marker.userData as? TakeoutEntity else {
                return false
            }

            // Show an alert with takeout details
            let alertController = UIAlertController(
                title: takeout.name,
                message: """
                Rating: \(String(format: "%.1f", takeout.rating)) ⭐
                Address: \(takeout.tagline ?? "No address")
                """,
                preferredStyle: .actionSheet
            )

            // Add action to get directions
            alertController.addAction(UIAlertAction(title: "Get Directions", style: .default) { _ in
                // Open Google Maps with directions
                if let name = takeout.name,
                   let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let url = URL(string: "comgooglemaps://?daddr=\(encodedName)&directionsmode=driving") {

                    // Check if Google Maps is installed
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        // Fallback to Apple Maps if Google Maps is not installed
                        let appleMapsURL = URL(string: "http://maps.apple.com/?daddr=\(encodedName)")!
                        UIApplication.shared.open(appleMapsURL, options: [:], completionHandler: nil)
                    }
                }
            })

            // Cancel action
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            // Present the alert
            if let topController = UIApplication.shared.windows.first?.rootViewController {
                topController.present(alertController, animated: true, completion: nil)
            }

            return true
        }
    }
}
