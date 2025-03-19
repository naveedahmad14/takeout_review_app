//
//  ReviewsScreen.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import Foundation
import SwiftUI

struct ReviewsScreen: View {
    let takeout: TakeoutEntity
    @State private var reviews: [ReviewEntity] = []
    @State private var isAddingReview = false

    // MARK: - Views
    private var takeoutHeader: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(takeout.name ?? "Takeout")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            HStack {
                Text("⭐")
                Text(String(format: "%.1f", takeout.rating))
                    .font(.title2)
            }
            .font(.title2)
        }
    }

    private var reviewsTitle: some View {
        Text("Reviews")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.gray)
            .padding(.top, 5)
    }

    private var addReviewButton: some View {
        Button(action: { isAddingReview = true }) {
            Text("Add Review ➜")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }

    private var reviewsList: some View {
        Group {
            if reviews.isEmpty {
                Text("No reviews available.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            } else {
                List(reviews) { review in
                    VStack(alignment: .leading) {
                        Text(review.reviewerName ?? "Anonymous")
                            .font(.headline)
                            .fontWeight(.bold)

                        Text("⭐ \(String(format: "%.1f", review.rating))")
                            .font(.subheadline)
                            .foregroundColor(.yellow)

                        Text(review.reviewDescription ?? "")
                            .font(.body)
                            .foregroundColor(.gray)
                            .padding(.top, 2)
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())
                .frame(height: 500)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            takeoutHeader
            reviewsTitle
            Divider()
            reviewsList
            Spacer()
            addReviewButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 5)
        .padding(.bottom, 20)
        .padding(.horizontal)
        .navigationTitle("Takeout Reviews")
        .onAppear { fetchReviews() }
        .sheet(isPresented: $isAddingReview, onDismiss: { fetchReviews() }) {
            AddReviewScreen(takeout: takeout)
        }
    }

    // MARK: - Functions
    private func fetchReviews() {
        reviews = PersistenceController.shared.fetchReviews(for: takeout)
    }
}
