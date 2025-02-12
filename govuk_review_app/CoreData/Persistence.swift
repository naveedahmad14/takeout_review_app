//
//  Persistence.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import CoreData

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
        takeout2.office = "London"

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
