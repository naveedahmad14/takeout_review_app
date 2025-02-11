//
//  HomeViewModel.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 28/01/2025.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var selectedOffice: String = "Manchester" {
        didSet {
            filterTakeouts() // Update takeouts when office changes
        }
    } // Tracks selected office

    let offices = ["Manchester", "London", "Bristol"]

    // Create mock reviews
    let mockReviews: [Review] = [
        Review(reviewerName: "Alice Johnson", rating: 4.5, description: "Great food and quick delivery."),
        Review(reviewerName: "Bob Smith", rating: 3.8, description: "Tasty, but a bit pricey."),
        Review(reviewerName: "Charlie Brown", rating: 4.2, description: "Loved the variety on the menu.")
    ]

    private var allTakeouts: [Takeout] = []

    // Sample Takeouts Data
    @Published var filteredTakeouts: [Takeout] = []

    init() {
        allTakeouts = [
            Takeout(name: "Burger Joint", rating: 4.5, tagline: "Best burgers in town!", office: "Manchester", reviews: mockReviews),
            Takeout(name: "Sushi Place", rating: 4.8, tagline: "Fresh sushi daily", office: "Manchester", reviews: mockReviews),
            Takeout(name: "Pizza Hub", rating: 4.2, tagline: "Delicious pizza and pasta", office: "Office 2", reviews: mockReviews),
            Takeout(name: "Vegan Bites", rating: 4.6, tagline: "Healthy and tasty!", office: "Bristol", reviews: mockReviews),
            Takeout(name: "Coffee Corner", rating: 4.7, tagline: "Best coffee around", office: "London", reviews: mockReviews),
            Takeout(name: "Taco Town", rating: 4.3, tagline: "Authentic Mexican flavors", office: "London", reviews: mockReviews)
        ]
        filterTakeouts() // Set initial takeouts
    }

    private func filterTakeouts() {
        filteredTakeouts = allTakeouts.filter { $0.office == selectedOffice }
    }
}
