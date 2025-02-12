//
//  HomeViewModel.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 28/01/2025.
//

import Foundation
import CoreData

class HomeViewModel: ObservableObject {
    @Published var filteredTakeouts: [TakeoutEntity] = []
    @Published var selectedOffice: String = "Manchester" {  // Default office
        didSet {
            fetchTakeouts() // Refresh list when selection changes
        }
    }

    private let context = PersistenceController.shared.context

    func fetchTakeouts() {
        let request: NSFetchRequest<TakeoutEntity> = TakeoutEntity.fetchRequest()
        request.predicate = NSPredicate(format: "office == %@", selectedOffice)

        do {
            filteredTakeouts = try context.fetch(request)
        } catch {
            print("Error fetching takeouts: \(error)")
        }
    }

    func addReview(takeout: TakeoutEntity, reviewerName: String, rating: Double, description: String) {
        PersistenceController.shared.addReview(to: takeout, reviewerName: reviewerName, rating: rating, description: description)
        fetchTakeouts()  // Refresh takeout list with updated reviews
    }

//    private func filterTakeouts() {
//        filteredTakeouts = allTakeouts.filter { $0.office == selectedOffice }
//    }
}
