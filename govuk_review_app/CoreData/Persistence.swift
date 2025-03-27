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
        OfficeLocation(name: "London", latitude: 51.507351, longitude: -0.127758)
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
            placeProperties: [GMSPlaceProperty.name, GMSPlaceProperty.formattedAddress, GMSPlaceProperty.coordinate, GMSPlaceProperty.rating, GMSPlaceProperty.photos].map { $0.rawValue })
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

            DispatchQueue.main.async {
                for takeout in takeouts {
                    self.addTakeout(newTakeout: takeout)
                }
                print("✅ Fetched and stored \(takeouts.count) takeouts")
            }
        }
        // Perform the search
        GMSPlacesClient.shared().searchNearby(with: request, callback: callback)
    }

    func addTakeout(newTakeout: NewTakeout) {
        // Check if data already exists to avoid duplication
        let fetchRequest: NSFetchRequest<TakeoutEntity> = TakeoutEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND office == %@", newTakeout.name, newTakeout.office)

        do {
            let existingData = try context.fetch(fetchRequest)
            if !existingData.isEmpty { return } // Skip if data exists
        } catch {
            print("Error checking existing data: \(error)")
        }

        let newTakeoutEntity = TakeoutEntity(context: context)
        newTakeoutEntity.id = UUID()
        newTakeoutEntity.name = newTakeout.name
        newTakeoutEntity.rating = newTakeout.rating
        newTakeoutEntity.tagline = newTakeout.tagline
        newTakeoutEntity.office = newTakeout.office

        saveContext()
    }

    func addMockData() {
        let context = self.context

        // Check if data already exists to avoid duplication
        let fetchRequest: NSFetchRequest<TakeoutEntity> = TakeoutEntity.fetchRequest()
        do {
            let existingData = try context.fetch(fetchRequest)
            if !existingData.isEmpty { return } // Skip if data exists
        } catch {
            print("Error checking existing data: \(error)")
        }

        // Create mock takeouts
        let takeout1 = TakeoutEntity(context: context)
        takeout1.id = UUID()
        takeout1.name = "Pizza Palace"
        takeout1.rating = 4.5
        takeout1.tagline = "Best pizza in town!"
        takeout1.office = "Manchester"

        let takeout2 = TakeoutEntity(context: context)
        takeout2.id = UUID()
        takeout2.name = "Sushi Spot"
        takeout2.rating = 4.2
        takeout2.tagline = "Fresh sushi and sashimi"
        takeout2.office = "Manchester"

        let takeout6 = TakeoutEntity(context: context)
        takeout6.id = UUID()
        takeout6.name = "Sushi Spot"
        takeout6.rating = 4.2
        takeout6.tagline = "Fresh sushi and sashimi"
        takeout6.office = "Manchester"

        let takeout7 = TakeoutEntity(context: context)
        takeout7.id = UUID()
        takeout7.name = "Sushi Spot"
        takeout7.rating = 4.2
        takeout7.tagline = "Fresh sushi and sashimi"
        takeout7.office = "Manchester"

        let takeout3 = TakeoutEntity(context: context)
        takeout3.id = UUID()
        takeout3.name = "Burger Haven"
        takeout3.rating = 4.8
        takeout3.tagline = "Juicy burgers and crispy fries!"
        takeout3.office = "Bristol"

        // Create mock reviews
        let review1 = ReviewEntity(context: context)
        review1.id = UUID()
        review1.reviewerName = "Alice"
        review1.rating = 5.0
        review1.reviewDescription = "Amazing pizza! Will definitely come back."
        review1.takeout = takeout1

        let review2 = ReviewEntity(context: context)
        review2.id = UUID()
        review2.reviewerName = "Bob"
        review2.rating = 3.5
        review2.reviewDescription = "Good sushi but a bit expensive."
        review2.takeout = takeout2

        let review3 = ReviewEntity(context: context)
        review3.id = UUID()
        review3.reviewerName = "Charlie"
        review3.rating = 4.8
        review3.reviewDescription = "Best burger I’ve ever had!"
        review3.takeout = takeout3

        // Save context
        saveContext()
        print("Mock data added successfully!")
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
