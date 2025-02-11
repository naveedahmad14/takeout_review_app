//
//  ReviewsScreen.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 15/01/2025.
//

import Foundation
import SwiftUI

struct ReviewsScreen: View {
    let takeout: Takeout

        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text(takeout.name)
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

                Divider()

                if takeout.reviews.isEmpty {
                    Text("No reviews available.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                } else {
                    List(takeout.reviews) { review in
                        VStack(alignment: .leading) {
                            Text(review.reviewerName)
                                .font(.headline)
                                .fontWeight(.bold)

                            Text("⭐ \(String(format: "%.1f", review.rating))")
                                .font(.subheadline)
                                .foregroundColor(.yellow)

                            Text(review.description)
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                        }
                        .padding(.vertical, 5)
                    }
                    .listStyle(PlainListStyle()) // Apply plain list style
                    .frame(height: 300) // Adjust height of list
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Align VStack to the left
            .padding(.leading, 5) // Adjust left padding
            .padding(.horizontal) // Ensure proper spacing on all sides
            .navigationTitle("Takeout Reviews")
            }
    }
