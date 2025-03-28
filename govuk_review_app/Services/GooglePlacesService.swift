//
//  GooglePlacesService.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 28/03/2025.
//

import Foundation
import GooglePlaces
import CoreLocation
import GoogleMaps

final class GooglePlacesService {
    static let shared = GooglePlacesService()

    private init() {}

    func initialize() {
        GMSServices.provideAPIKey("AIzaSyC3YyhL4sC5fWp59cDn5Ek7IqErZuRdNB4")
        GMSPlacesClient.provideAPIKey("AIzaSyAKWNWlKobef5VQKTApBeirRY2pLirGqjU")
    }

    private let placesClient = GMSPlacesClient.shared()

    struct TakeoutPlace {
        let placeID: String
        let name: String
        let rating: Double
        let tagline: String
        let coordinate: CLLocationCoordinate2D
        let office: String
    }

    struct OfficeLocation {
        let name: String
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
    }

    let offices: [OfficeLocation] = [
        OfficeLocation(name: "Manchester", latitude: 53.478221, longitude: -2.242756),
        OfficeLocation(name: "Bristol", latitude: 51.454514, longitude: -2.587910),
        OfficeLocation(name: "London", latitude: 51.514466679975286, longitude: -0.07289043154882537)
    ]

    private let includedTypes = [
        "fast_food_restaurant", "meal_takeaway", "meal_delivery", "restaurant",
        "diner", "sandwich_shop", "hamburger_restaurant", "pizza_restaurant",
        "deli", "bagel_shop", "brunch_restaurant", "breakfast_restaurant",
        "cafe", "coffee_shop", "juice_shop", "tea_house",
        "vegan_restaurant", "vegetarian_restaurant"
    ]

    private let excludedTypes = [
        "fine_dining_restaurant", "bar_and_grill", "steak_house", "wine_bar",
        "bar", "pub", "night_club", "grocery_store", "shopping_mall",
        "store", "hotel", "buffet_restaurant", "banquet_hall", "food_court"
    ]

    /// Fetch takeouts near a given office location.
    func fetchNearbyTakeouts(for office: OfficeLocation, completion: @escaping ([TakeoutPlace]) -> Void) {
        let searchLocation = CLLocationCoordinate2D(latitude: office.latitude, longitude: office.longitude)
        let radiusInMeters: CLLocationDistance = 1000

        var request = GMSPlaceSearchNearbyRequest(
            locationRestriction: GMSPlaceCircularLocationOption(searchLocation, radiusInMeters),
            placeProperties: [
                GMSPlaceProperty.placeID,
                GMSPlaceProperty.name,
                GMSPlaceProperty.formattedAddress,
                GMSPlaceProperty.coordinate,
                GMSPlaceProperty.rating
            ].map { $0.rawValue }
        )

        request.includedTypes = includedTypes
        request.excludedTypes = excludedTypes

        placesClient.searchNearby(with: request) { results, error in
            guard error == nil, let places = results as? [GMSPlace] else {
                print("❌ Error fetching places: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            let takeouts = places.prefix(15).map { place in
                TakeoutPlace(
                    placeID: place.placeID ?? "",
                    name: place.name ?? "Unknown",
                    rating: Double(place.rating) ?? 0.0,
                    tagline: place.formattedAddress ?? "No address",
                    coordinate: place.coordinate,
                    office: office.name
                )
            }
            completion(takeouts)
        }
    }

    /// Fetch photos for a given place.
    func fetchPlacePhotos(for placeID: String, completion: @escaping ([Data]) -> Void) {
        var fields = GMSPlaceField()
        fields.insert(.photos)

        placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) { fetchedPlace, error in
            guard let fetchedPlace = fetchedPlace, let photos = fetchedPlace.photos, !photos.isEmpty else {
                completion([])
                return
            }

            let dispatchGroup = DispatchGroup()
            var imageDataArray: [Data] = []

            for photoMetadata in photos.prefix(3) {
                dispatchGroup.enter()
                self.placesClient.loadPlacePhoto(photoMetadata) { (photo, error) in
                    defer { dispatchGroup.leave() }
                    if let photo = photo, let imageData = photo.jpegData(compressionQuality: 0.8) {
                        imageDataArray.append(imageData)
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(imageDataArray)
            }
        }
    }
}
