//
//  HomeViewModel.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 28/01/2025.
//

import Foundation
import CoreData

class HomeViewModel: ObservableObject {
    @Published var filteredTakeouts: [Takeout] = []
    private var allTakeouts: [Takeout] = [] // Keep a reference to all mock takeouts
    @Published var selectedOffice: String = "Manchester" {  // Default office
        didSet {
            filterTakeouts() // Refresh list when selection changes
        }
    }

    private let context = PersistenceController.shared.context

    init () {
        addMockData()
        //fetchTakeouts()
    }

    func addMockData() {
        // Mock takeouts (no Core Data involved)
        let mockTakeouts = [
            Takeout(name: "Pizza Palace", rating: 4.5, office: "Manchester", tagline: "Best pizza in town!"),
            Takeout(name: "Sushi Spot", rating: 4.2, office: "London", tagline: "Fresh sushi and sashimi"),
            Takeout(name: "Burger Haven", rating: 4.8, office: "Bristol", tagline: "Juicy burgers and crispy fries!")
        ]

        self.allTakeouts = mockTakeouts
        filterTakeouts() // Filter based on the office selection
    }

    func fetchTakeouts() {
        guard let url = URL(string: "https://yourapi.com/takeouts") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedTakeouts = try JSONDecoder().decode([Takeout].self, from: data)
                    DispatchQueue.main.async {
                        self.filteredTakeouts = decodedTakeouts
                        self.filterTakeouts()
                    }
                } catch {
                    print("Error decoding takeouts: \(error)")
                }
            }
        }.resume()
    }

    func addReview(takeout: Takeout, reviewerName: String, rating: Double, description: String) {
        PersistenceController.shared.addReview(
            for: takeout,
            reviewerName: reviewerName,
            rating: rating,
            description: description
        )
        fetchTakeouts()  // Refresh takeout list with updated reviews
    }

    private func filterTakeouts() {
        self.filteredTakeouts = allTakeouts.filter { $0.office == selectedOffice }
    }
}
