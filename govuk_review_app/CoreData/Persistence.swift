//
//  Persistence.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import CoreData
import GooglePlaces
import CoreLocation

struct PersistenceController {
    // MARK: - Singleton Instance
    static let shared = PersistenceController()

    // Dependency on GooglePlacesService
    private let placesService = GooglePlacesService.shared

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

    // MARK: - Distance Calculation
    func distanceBetweenCoordinates(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDistance {
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let endLocation = CLLocation(latitude: end.latitude, longitude: end.longitude)
        return startLocation.distance(from: endLocation)
    }

    // MARK: - Place Fetching
    func addData() {
        placesService.offices.forEach { office in
            fetchNearbyTakeouts(for: office)
        }
    }

    private func fetchNearbyTakeouts(for office: GooglePlacesService.OfficeLocation) {
        placesService.fetchNearbyTakeouts(for: office) { takeouts in
            DispatchQueue.main.async {
                takeouts.forEach { takeout in
                    self.fetchAndAddPhotos(for: takeout)
                }
                print("Fetched and processed \(takeouts.count) takeouts for \(office.name)")
            }
        }
    }

    private func fetchAndAddPhotos(for takeout: GooglePlacesService.TakeoutPlace) {
        placesService.fetchPlacePhotos(for: takeout.placeID) { imageDataArray in
            DispatchQueue.main.async {
                self.addTakeout(takeout: takeout, imageDataArray: imageDataArray)
            }
        }
    }

    // MARK: - Takeout Management
    func addTakeout(takeout: GooglePlacesService.TakeoutPlace, imageDataArray: [Data]) {
        let fetchRequest: NSFetchRequest<TakeoutEntity> = TakeoutEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND office == %@", takeout.name, takeout.office)

        do {
            let existingData = try context.fetch(fetchRequest)
            guard existingData.isEmpty else { return }

            let takeoutEntity = TakeoutEntity(context: context)
            takeoutEntity.id = UUID()
            takeoutEntity.name = takeout.name
            takeoutEntity.rating = takeout.rating
            takeoutEntity.tagline = takeout.tagline
            takeoutEntity.latitude = takeout.coordinate.latitude
            takeoutEntity.longitude = takeout.coordinate.longitude
            takeoutEntity.office = takeout.office
            takeoutEntity.imageDataArray = imageDataArray

            saveContext()
            print("Saved \(imageDataArray.count) images for \(takeout.name)")
        } catch {
            print("Error checking/saving takeout: \(error.localizedDescription)")
        }
    }
}
