//
//  Persistence.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import CoreData
import GooglePlaces

struct PersistenceController {
    // MARK: - Singleton Instance
    static let shared = PersistenceController()

    // MARK: - Core Data Properties
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }

    // MARK: - Initialization
    init() {
        container = NSPersistentContainer(name: "govuk_review_app")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved CoreData error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Context Management
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("CoreData save error: \(error.localizedDescription)")
        }
    }

    // MARK: - Review Management
    func addReview(to takeout: TakeoutEntity, reviewerName: String, rating: Double, description: String) {
        let review = ReviewEntity(context: context)
        review.id = UUID()
        review.reviewerName = reviewerName
        review.rating = rating
        review.reviewDescription = description
        review.takeout = takeout
        saveContext()
    }

    func fetchReviews(for takeout: TakeoutEntity) -> [ReviewEntity] {
        let request: NSFetchRequest<ReviewEntity> = ReviewEntity.fetchRequest()
        request.predicate = NSPredicate(format: "takeout == %@", takeout)

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch reviews: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Location and Takeout Helpers
    struct NewTakeout {
        let name: String
        let rating: Double
        let tagline: String
        let office: String
    }

    struct OfficeLocation {
        let name: String
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
    }

    let offices = [
        OfficeLocation(name: "Manchester", latitude: 53.478221, longitude: -2.242756),
        OfficeLocation(name: "Bristol", latitude: 51.454514, longitude: -2.587910),
        OfficeLocation(name: "London", latitude: 51.514466679975286, longitude: -0.07289043154882537)
    ]

    // MARK: - Distance Calculation
    func distanceBetweenCoordinates(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDistance {
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
        return startLocation.distance(from: endLocation)
    }

    // MARK: - Place Fetching
    func addData() {
        offices.forEach { office in
            fetchNearbyTakeouts(
                name: office.name,
                latitude: office.latitude,
                longitude: office.longitude
            )
        }
    }

    private func fetchNearbyTakeouts(name: String, latitude: Double, longitude: Double) {
        let searchLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radiusInMeters: CLLocationDistance = 1000

        let includedTypes = [
          "fast_food_restaurant",
          "meal_takeaway",
          "meal_delivery",
          "restaurant",
          "diner",
          "sandwich_shop",
          "hamburger_restaurant",
          "pizza_restaurant",
          "deli",
          "bagel_shop",
          "brunch_restaurant",
          "breakfast_restaurant",
          "cafe",
          "coffee_shop",
          "juice_shop",
          "tea_house",
          "vegan_restaurant",
          "vegetarian_restaurant"
        ];

        let excludedTypes = [
          "fine_dining_restaurant",
          "bar_and_grill",
          "steak_house",
          "wine_bar",
          "bar",
          "pub",
          "night_club",
          "grocery_store",
          "shopping_mall",
          "store",
          "hotel",
          "buffet_restaurant",
          "banquet_hall",
          "food_court"
        ];

        var request = GMSPlaceSearchNearbyRequest(
            locationRestriction: GMSPlaceCircularLocationOption(searchLocation, radiusInMeters),
            placeProperties: [
                GMSPlaceProperty.placeID.rawValue,
                GMSPlaceProperty.name.rawValue,
                GMSPlaceProperty.formattedAddress.rawValue,
                GMSPlaceProperty.coordinate.rawValue,
                GMSPlaceProperty.rating.rawValue
            ]
        )
        request.includedTypes = includedTypes
        request.excludedTypes = excludedTypes

        GMSPlacesClient.shared().searchNearby(with: request) { results, error in
            self.handlePlaceSearchResults(results, error, searchLocation, name)
        }
    }

    private func handlePlaceSearchResults(_ results: [Any]?, _ error: Error?, _ searchLocation: CLLocationCoordinate2D, _ officeName: String) {
        guard error == nil else {
            print("Error fetching places: \(error!.localizedDescription)")
            return
        }

        guard let places = results as? [GMSPlace] else {
            print("No places found.")
            return
        }

        let filteredPlaces = places.filter { place in
            guard let types = place.types else { return true }
            return !types.contains { ["lodging", "hotel"].contains($0) }
        }

        let sortedPlaces = filteredPlaces.sorted { place1, place2 in
            let distance1 = distanceBetweenCoordinates(from: searchLocation, to: place1.coordinate)
            let distance2 = distanceBetweenCoordinates(from: searchLocation, to: place2.coordinate)
            return distance1 < distance2
        }

        let topPlaces = Array(sortedPlaces.prefix(15))

        DispatchQueue.main.async {
            topPlaces.forEach { place in
                self.fetchPlacePhotos(for: place, officeName: officeName)
            }
            print("Fetched and processed \(topPlaces.count) takeouts")
        }
    }

    // MARK: - Photo Fetching
    private func fetchPlacePhotos(for place: GMSPlace, officeName: String) {
        guard let placeID = place.placeID else {
            addTakeout(newTakeout: place, office: officeName, imageDataArray: [])
            return
        }

        let placesClient = GMSPlacesClient.shared()
        var fields = GMSPlaceField()
        fields.insert(.photos)

        placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) { fetchedPlace, error in
            self.handlePlacePhotoFetching(place: place, fetchedPlace: fetchedPlace, error: error, officeName: officeName)
        }
    }

    private func handlePlacePhotoFetching(place: GMSPlace, fetchedPlace: GMSPlace?, error: Error?, officeName: String) {
        if let error = error {
            print("Error fetching place details: \(error.localizedDescription)")
            addTakeout(newTakeout: place, office: officeName, imageDataArray: [])
            return
        }

        guard let photos = fetchedPlace?.photos, !photos.isEmpty else {
            addTakeout(newTakeout: place, office: officeName, imageDataArray: [])
            return
        }

        let photosToFetch = Array(photos.prefix(3))
        var imageDataArray: [Data] = []
        let dispatchGroup = DispatchGroup()

        photosToFetch.forEach { photoMetadata in
            dispatchGroup.enter()
            GMSPlacesClient.shared().loadPlacePhoto(photoMetadata) { photo, error in
                defer { dispatchGroup.leave() }

                if let error = error {
                    print("Error loading photo: \(error.localizedDescription)")
                    return
                }

                if let photo = photo,
                   let imageData = photo.jpegData(compressionQuality: 0.8) {
                    imageDataArray.append(imageData)
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.addTakeout(newTakeout: place, office: officeName, imageDataArray: imageDataArray)
        }
    }

    // MARK: - Takeout Management
    func addTakeout(newTakeout: GMSPlace, office: String, imageDataArray: [Data]) {
        let fetchRequest: NSFetchRequest<TakeoutEntity> = TakeoutEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND office == %@", newTakeout.name ?? "", office)

        do {
            let existingData = try context.fetch(fetchRequest)
            guard existingData.isEmpty else { return }

            let takeoutEntity = TakeoutEntity(context: context)
            takeoutEntity.id = UUID()
            takeoutEntity.name = newTakeout.name
            takeoutEntity.rating = Double(newTakeout.rating ?? 0.0)
            takeoutEntity.tagline = newTakeout.formattedAddress ?? "No address"
            takeoutEntity.latitude = newTakeout.coordinate.latitude
            takeoutEntity.longitude = newTakeout.coordinate.longitude
            takeoutEntity.office = office
            takeoutEntity.imageDataArray = imageDataArray

            saveContext()
            print("Saved \(imageDataArray.count) images for \(newTakeout.name ?? "Unknown Place")")
        } catch {
            print("Error checking/saving takeout: \(error.localizedDescription)")
        }
    }
}
