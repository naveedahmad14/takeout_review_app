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

    var addReviewButton: some View {
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

        var body: some View {
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

                Text("Reviews")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding(.top, 5)

                addReviewButton

                Divider()

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
                    .frame(height: 300)
                }

                Spacer()
                
            }
            
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 5)
            .padding(.horizontal)
            .navigationTitle("Takeout Reviews")
            .onAppear {
                reviews = PersistenceController.shared.fetchReviews(for: takeout)
            }
            .sheet(isPresented: $isAddingReview, onDismiss: {
                fetchReviews() // Refresh reviews when AddReviewScreen is closed
            }) {
                AddReviewScreen(takeout: takeout)
            }
        }

    private func fetchReviews() {
        reviews = PersistenceController.shared.fetchReviews(for: takeout)
    }

}
