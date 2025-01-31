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
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    Text(takeout.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    Text("Reviews")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                        .padding(.top, -5)

                    HStack {
                        Text("⭐")
                        Text(String(format: "%.1f", takeout.rating))
                            .font(.title2)
                    }
                    .font(.title2)

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Moves VStack to the left
                .padding(.leading, 5) // Adjusts left padding
                .padding(.horizontal) // Ensures proper spacing on all sides
            }
            .navigationTitle("Takeout Reviews")
        }
}

struct ReviewsScreen_Preview: PreviewProvider {
    static var previews: some View {
        ReviewsScreen(takeout: Takeout(name: "Sample", rating: 4.5, tagline: "Best in town!", office: "London"))
    }
}
