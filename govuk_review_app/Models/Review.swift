//
//  Review.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 29/01/2025.
//

import Foundation

struct Review: Identifiable {
    let id = UUID()
    let reviewerName: String
    let rating: Double
    let description: String
}
