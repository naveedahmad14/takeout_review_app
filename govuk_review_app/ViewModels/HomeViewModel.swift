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

    // Sample Takeouts Data
    private let allTakeouts: [Takeout] = [
        Takeout(name: "Burger Joint", rating: 4.5, tagline: "Best burgers in town!", office: "Manchester"),
        Takeout(name: "Sushi Place", rating: 4.8, tagline: "Fresh sushi daily", office: "Manchester"),
        Takeout(name: "Pizza Hub", rating: 4.2, tagline: "Delicious pizza and pasta", office: "Office 2"),
        Takeout(name: "Vegan Bites", rating: 4.6, tagline: "Healthy and tasty!", office: "Bristol"),
        Takeout(name: "Coffee Corner", rating: 4.7, tagline: "Best coffee around", office: "London"),
        Takeout(name: "Taco Town", rating: 4.3, tagline: "Authentic Mexican flavors", office: "London")
    ]
    @Published var filteredTakeouts: [Takeout] = []

    init() {
        filterTakeouts() // Set initial takeouts
    }

    private func filterTakeouts() {
        filteredTakeouts = allTakeouts.filter { $0.office == selectedOffice }
    }
}
