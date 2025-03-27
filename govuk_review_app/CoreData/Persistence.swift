//
//  Persistence.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import CoreData
import GooglePlaces

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "govuk_review_app")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return container.viewContext
    }

    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving CoreData: \(error)")
        }
    }

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
            print("Failed to fetch reviews: \(error)")
            return []
        }
    }

    struct NewTakeout {
        let name: String
        let rating: Double
        let tagline: String
        let office: String
        //let photoURLs: [String]?
    }

    // Helper function to calculate the distance between two coordinates
    func distanceBetweenCoordinates(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDistance {
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
        return startLocation.distance(from: endLocation)
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

    func addData() {
        for office in offices {
            fetchNearbyTakeouts(name: office.name,  latitude: office.latitude, longitude: office.longitude)
        }
    }

    func fetchNearbyTakeouts(name: String, latitude: Double, longitude: Double) {
        let placesClient = GMSPlacesClient.shared()

        // Create the search area with a 1000-meter radius
        let searchLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radiusInMeters: CLLocationDistance = 1000 // Search within 500 meters

        // Define the place types you are interested in (e.g., restaurants and cafes)
        let includedTypes = ["meal_takeaway", "fast_food_restaurant", "cafe"]
        let exludedTypes = ["hotel", "shopping_mall", "store"]

        // Set up the GMSPlaceSearchNearbyRequest
        var request = GMSPlaceSearchNearbyRequest(
            locationRestriction: GMSPlaceCircularLocationOption(searchLocation, radiusInMeters),
            placeProperties: [GMSPlaceProperty.placeID, GMSPlaceProperty.name, GMSPlaceProperty.formattedAddress, GMSPlaceProperty.coordinate, GMSPlaceProperty.rating].map { $0.rawValue })
        request.includedTypes = includedTypes
        request.excludedTypes = exludedTypes

        // Define the callback to handle the search results
        let callback: GMSPlaceSearchNearbyResultCallback = { results, error in
            guard error == nil else {
                print("❌ Error fetching places: \(error!.localizedDescription)")
                return
            }

            guard let places = results as? [GMSPlace] else {
                print("⚠️ No places found.")
                return
            }

            let filteredPlaces = places.filter { place in
                guard let types = place.types else { return true } // Keep it if no types are defined
                return !types.contains("lodging") && !types.contains("hotel")
            }

            // Sort the places by distance from the office
            let sortedPlaces = filteredPlaces.sorted { (place1, place2) -> Bool in
                let distance1 = self.distanceBetweenCoordinates(from: searchLocation, to: place1.coordinate)
                let distance2 = self.distanceBetweenCoordinates(from: searchLocation, to: place2.coordinate)
                return distance1 < distance2 // Sort by closest to furthest
            }

            // Limit to top 15 places
            let takeouts = sortedPlaces.prefix(15).map { place -> NewTakeout in
                return NewTakeout(
                    name: place.name ?? "Unknown",
                    rating: Double(place.rating ?? 0.0),
                    tagline: place.formattedAddress ?? "No address",
                    office: name // Hardcoding the office location
                    //photoURLs: photoMetadata // Store photo metadata references
                )
            }

            var placeResults: [GMSPlace] = []
            placeResults = places

            for place in places {
                self.fetchPlacePhotos(for: place, officeName: name)
            }


            DispatchQueue.main.async {
                for place in places {
                    self.fetchPlacePhotos(for: place, officeName: name)
                }
                print("✅ Fetched and stored \(takeouts.count) takeouts")
            }
        }
        // Perform the search
        GMSPlacesClient.shared().searchNearby(with: request, callback: callback)
    }

    func fetchPlacePhotos(for place: GMSPlace, officeName: String) {
        guard let placeID = place.placeID else {
            print("❌ No Place ID for \(place.name ?? "Unknown Place")")
            DispatchQueue.main.async {
                self.addTakeout(newTakeout: place, office: officeName, imageDataArray: [])
            }
            return
        }

        let placesClient = GMSPlacesClient.shared()

        // Properly specify photo fields
        var fields = GMSPlaceField()
        fields.insert(.photos)

        // Create a cancellation flag
        var isCancelled = false

        // Add a timeout mechanism
        let timeoutWorkItem = DispatchWorkItem { [self] in
            guard !isCancelled else { return }
            print("⏰ Photo fetch timed out for \(place.name ?? "Unknown Place")")
            DispatchQueue.main.async {
                self.addTakeout(newTakeout: place, office: officeName, imageDataArray: [])
            }
        }

        // Schedule the timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: timeoutWorkItem)

        // Fetch place with specific fields
        placesClient.fetchPlace(
            fromPlaceID: placeID,
            placeFields: fields,
            sessionToken: nil
        ) { (fetchedPlace: GMSPlace?, error: Error?) in
            // Mark as completed to prevent timeout action
            isCancelled = true
            timeoutWorkItem.cancel()

            // Error handling
            if let error = error {
                print("❌ Error fetching place details: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.addTakeout(newTakeout: place, office: officeName, imageDataArray: [])
                }
                return
            }

            // Check if place has photos
            guard let fetchedPlace = fetchedPlace,
                  let photos = fetchedPlace.photos,
                  !photos.isEmpty else {
                print("⚠️ No photos found for \(place.name ?? "Unknown Place")")
                DispatchQueue.main.async {
                    self.addTakeout(newTakeout: place, office: officeName, imageDataArray: [])
                }
                return
            }

            // Limit to first 3 photos
            let photosToFetch = Array(photos.prefix(3))
            var imageDataArray: [Data] = []

            let dispatchGroup = DispatchGroup()

            for photoMetadata in photosToFetch {
                dispatchGroup.enter()

                placesClient.loadPlacePhoto(photoMetadata) { (photo, error) in
                    defer { dispatchGroup.leave() }

                    if let error = error {
                        print("❌ Error loading photo: \(error.localizedDescription)")
                        return
                    }

                    if let photo = photo,
                       let imageData = photo.jpegData(compressionQuality: 0.8) {
                        print("✅ Successfully fetched photo for \(place.name ?? "Unknown Place")")
                        imageDataArray.append(imageData)
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                print("📸 Total images fetched for \(place.name ?? "Unknown Place"): \(imageDataArray.count)")
                self.addTakeout(newTakeout: place, office: officeName, imageDataArray: imageDataArray)
            }
        }
    }

    func addTakeout(newTakeout: GMSPlace, office: String, imageDataArray: [Data]) {
        let fetchRequest: NSFetchRequest<TakeoutEntity> = TakeoutEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND office == %@", newTakeout.name ?? "", office)

        do {
            let existingData = try context.fetch(fetchRequest)
            if !existingData.isEmpty { return } // Skip if data exists
        } catch {
            print("Error checking existing data: \(error)")
        }

        let takeoutEntity = TakeoutEntity(context: context)
        takeoutEntity.id = UUID()
        takeoutEntity.name = newTakeout.name
        takeoutEntity.rating = Double(newTakeout.rating ?? 0.0)
        takeoutEntity.tagline = newTakeout.formattedAddress ?? "No address"
        takeoutEntity.latitude = newTakeout.coordinate.latitude
        takeoutEntity.longitude = newTakeout.coordinate.longitude
        takeoutEntity.office = office

        // Directly assign the image data array
        takeoutEntity.imageDataArray = imageDataArray
        print("✅ Saving \(imageDataArray.count) images for \(newTakeout.name ?? "Unknown Place")")

        saveContext()
    }

    func deleteAllData() {
        let context = self.context

        let takeoutFetchRequest: NSFetchRequest<NSFetchRequestResult> = TakeoutEntity.fetchRequest()
        let reviewFetchRequest: NSFetchRequest<NSFetchRequestResult> = ReviewEntity.fetchRequest()

        let takeoutDeleteRequest = NSBatchDeleteRequest(fetchRequest: takeoutFetchRequest)
        let reviewDeleteRequest = NSBatchDeleteRequest(fetchRequest: reviewFetchRequest)

        do {
            try context.execute(takeoutDeleteRequest)
            try context.execute(reviewDeleteRequest)
            saveContext()
            print("All mock data deleted successfully!")
        } catch {
            print("Error deleting mock data: \(error)")
        }
    }
}
