//
//  MapView.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 17/03/2025.
//

import SwiftUI
import GoogleMaps
import GooglePlaces

struct MapView: UIViewRepresentable {
    var takeouts: [TakeoutEntity]
    var selectedOffice: String

    // Office locations with their coordinates and default zoom levels
    private let officeLocations: [String: (latitude: Double, longitude: Double, zoom: Float)] = [
        "London": (51.514466679975286, -0.07289043154882537, 14.25),
        "Manchester": (53.478221, -2.242756, 14),
        "Bristol": (51.45144871492796, -2.5787365711638883, 14)
    ]

    func makeUIView(context: Context) -> GMSMapView {
        // Get the office location or use a default
        let (initialLatitude, initialLongitude, initialZoom) = officeLocations[selectedOffice] ?? (53.4832662, -2.2414207, 12)

        let camera = GMSCameraPosition.camera(withLatitude: initialLatitude, longitude: initialLongitude, zoom: initialZoom)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.delegate = context.coordinator

        // Add markers for takeouts in the selected office
        addMarkers(to: mapView)

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
        addMarkers(to: uiView)
    }

    private func addMarkers(to mapView: GMSMapView) {
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
            marker.map = mapView
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
            super.init()
        }

        // Custom info window content
        func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
            guard let takeout = marker.userData as? TakeoutEntity else {
                return nil
            }

            // Create a container view
            let infoWindow = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 120))
            infoWindow.backgroundColor = UIColor.white
            infoWindow.layer.cornerRadius = 8
            infoWindow.clipsToBounds = true

            // Title label
            let titleLabel = UILabel(frame: CGRect(x: 10, y: 5, width: 220, height: 22))
            titleLabel.text = takeout.name
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)

            // Address label
            let addressLabel = UILabel(frame: CGRect(x: 10, y: 27, width: 220, height: 36))
            addressLabel.text = takeout.tagline
            addressLabel.font = UIFont.systemFont(ofSize: 12)
            addressLabel.numberOfLines = 2

            // Rating label
            let ratingLabel = UILabel(frame: CGRect(x: 10, y: 65, width: 220, height: 20))
            ratingLabel.text = "Rating: \(String(format: "%.1f", takeout.rating)) ⭐"
            ratingLabel.font = UIFont.systemFont(ofSize: 14)

            // Directions button
            let buttonWidth: CGFloat = 140
            let buttonHeight: CGFloat = 30
            let buttonX = (infoWindow.frame.width - buttonWidth) / 2 // Centering calculation
            let buttonY: CGFloat = 85

            // Directions button
            let directionsButton = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight))
            directionsButton.setTitle("Get Directions", for: .normal)
            directionsButton.backgroundColor = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1.0)
            directionsButton.layer.cornerRadius = 5
            directionsButton.tag = 1 // Tag to identify this button in delegate
            directionsButton.addTarget(self, action: #selector(self.handleInfoWindowTap), for: .touchUpInside)

            // Add all elements to container
            infoWindow.addSubview(titleLabel)
            infoWindow.addSubview(addressLabel)
            infoWindow.addSubview(ratingLabel)
            infoWindow.addSubview(directionsButton)

            return infoWindow
        }

        // Track the currently selected marker to use with the directions button
        var selectedMarker: GMSMarker?

        // Handle marker taps
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            selectedMarker = marker
            return false // Allow default behavior to show info window
        }

        // Handle info window taps
        func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
            openDirections(for: marker)
        }

        // Handle button taps within info window
        @objc func handleInfoWindowTap(_ sender: UIButton) {
            if sender.tag == 1, let marker = selectedMarker {
                openDirections(for: marker)
            }
        }

        // Open directions to the selected location
        private func openDirections(for marker: GMSMarker) {
            guard let takeout = marker.userData as? TakeoutEntity,
                  let name = takeout.name else {
                return
            }

            // Options to try in order of preference:
            // 1. Use coordinates directly (most precise)
            // 2. Use place name with coordinates as context

            let position = marker.position
            let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

            // Try to open in Google Maps using coordinates first
            let googleMapsURL = URL(string: "comgooglemaps://?daddr=\(position.latitude),\(position.longitude)&directionsmode=driving&zoom=15")!

            if UIApplication.shared.canOpenURL(googleMapsURL) {
                UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
            } else {
                // Fallback to Apple Maps with coordinates
                let appleMapsURL = URL(string: "http://maps.apple.com/?daddr=\(position.latitude),\(position.longitude)")!
                UIApplication.shared.open(appleMapsURL, options: [:], completionHandler: nil)
            }
        }
    }
}

// Extension to use the place ID if available in your data model
extension TakeoutEntity {
    // This function helps get the most precise location identifier for directions
    func getLocationIdentifier() -> String {
        if let name = self.name {
            // If the tagline contains an address, use that for better precision
            if let address = self.tagline, !address.isEmpty {
                return "\(name), \(address)"
            }
            return name
        }

        // Fall back to coordinates if name is not available
        return "\(self.latitude),\(self.longitude)"
    }
}
