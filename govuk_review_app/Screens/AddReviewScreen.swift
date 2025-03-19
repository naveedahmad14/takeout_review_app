//
//  AddReviewScreen.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import SwiftUI

struct AddReviewScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss // To close the screen after submitting

    var takeout: TakeoutEntity // The takeout being reviewed

    @State private var reviewerName: String = ""
    @State private var reviewText: String = ""
    @State private var rating: Double = 3.0 // Default rating

    // MARK: - Rating Slider
    private var ratingSlider: some View {
        VStack(alignment: .leading) {
            Text("Rating: \(String(format: "%.1f", rating)) ⭐️")
            Slider(value: $rating, in: 1...5, step: 0.1)
        }
        .padding(.horizontal)
    }

    // MARK: - Review Input Fields
    private var reviewInputFields: some View {
        VStack(spacing: 20) {
            TextField("Your name (optional)", text: $reviewerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            ratingSlider

            TextEditor(text: $reviewText)
                .frame(height: 150)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal)
        }
    }

    // MARK: - Submit Button
    private var submitButton: some View {
        Button(action: submitReview) {
            Text("Add Review ➜")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                reviewInputFields
                submitButton
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Add Review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Submit Review Function
    // Access the shared instance of PersistenceController to interact with Core Data.
    // Using a singleton ensures that all database operations use the same managed object context,
    // preventing redundant instances and maintaining data consistency throughout the app.
    private func submitReview() {
        let persistenceController = PersistenceController.shared
        // Add the review to Core Data
        persistenceController.addReview(
            to: takeout,
            reviewerName: reviewerName.isEmpty ? "Anonymous" : reviewerName,
            rating: rating,
            description: reviewText
        )
        // close addReview screen
        dismiss()
    }
}
