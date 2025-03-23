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

    func addReview(for takeout: Takeout, reviewerName: String, rating: Double, description: String) {
            let review = ReviewEntity(context: context)
            review.id = UUID()
            review.reviewerName = reviewerName.isEmpty ? "Anonymous" : reviewerName
            review.rating = rating
            review.reviewDescription = description
            review.takeoutId = takeout.id
            saveContext()
        }

    func fetchReviews(for takeout: Takeout) -> [ReviewEntity] {
        let request: NSFetchRequest<ReviewEntity> = ReviewEntity.fetchRequest()
        request.predicate = NSPredicate(format: "takeoutId == %@", takeout.id.uuidString)
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch reviews: \(error)")
            return []
        }
    }

//    func addMockData() {
//        let context = self.context
//
//        // Check if data already exists to avoid duplication
//        let fetchRequest: NSFetchRequest<ReviewEntity> = ReviewEntity.fetchRequest()
//        do {
//            let existingReviews = try context.fetch(fetchRequest)
//            if !existingReviews.isEmpty { return } // Skip if data exists
//        } catch {
//            print("Error checking existing reviews: \(error)")
//        }
//
//        // Mock takeouts (we no longer store these in Core Data, only use them for mock data)
//        let mockTakeouts = [
//            Takeout(name: "Pizza Palace", rating: 4.5, office: "Manchester", tagline: "Best pizza in town!"),
//            Takeout(name: "Sushi Spot", rating: 4.2, office: "London", tagline: "Fresh sushi and sashimi"),
//            Takeout(name: "Burger Haven", rating: 4.8, office: "Bristol", tagline: "Juicy burgers and crispy fries!")
//        ]
//
//        // Create mock reviews
//        let review1 = ReviewEntity(context: context)
//        review1.id = UUID()
//        review1.reviewerName = "Alice"
//        review1.rating = 5.0
//        review1.reviewDescription = "Amazing pizza! Will definitely come back."
//        review1.takeoutId = mockTakeouts[0].id // Reference Takeout's UUID
//
//        let review2 = ReviewEntity(context: context)
//        review2.id = UUID()
//        review2.reviewerName = "Bob"
//        review2.rating = 3.5
//        review2.reviewDescription = "Good sushi but a bit expensive."
//        review2.takeoutId = mockTakeouts[1].id // Reference Takeout's UUID
//
//        let review3 = ReviewEntity(context: context)
//        review3.id = UUID()
//        review3.reviewerName = "Charlie"
//        review3.rating = 4.8
//        review3.reviewDescription = "Best burger I’ve ever had!"
//        review3.takeoutId = mockTakeouts[2].id // Reference Takeout's UUID
//
//        saveContext()
//
//    }


    func deleteReview(_ review: ReviewEntity) {
        context.delete(review)
        saveContext()
    }

    func deleteAllReviews(for takeout: Takeout) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ReviewEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "takeoutId == %@", takeout.id.uuidString)

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            saveContext()
            print("All reviews for \(takeout.name) deleted successfully!")
        } catch {
            print("Error deleting reviews: \(error)")
        }
    }
//    func deleteAllData() {
//        let context = self.context
//
//        let takeoutFetchRequest: NSFetchRequest<NSFetchRequestResult> = TakeoutEntity.fetchRequest()
//        let reviewFetchRequest: NSFetchRequest<NSFetchRequestResult> = ReviewEntity.fetchRequest()
//
//        let takeoutDeleteRequest = NSBatchDeleteRequest(fetchRequest: takeoutFetchRequest)
//        let reviewDeleteRequest = NSBatchDeleteRequest(fetchRequest: reviewFetchRequest)
//
//        do {
//            try context.execute(takeoutDeleteRequest)
//            try context.execute(reviewDeleteRequest)
//            saveContext()
//            print("All mock data deleted successfully!")
//        } catch {
//            print("Error deleting mock data: \(error)")
//        }
//    }
}

