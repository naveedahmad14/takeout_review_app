//
//  Takeout.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 28/01/2025.
//

import Foundation

struct Takeout: Identifiable {
    let id = UUID()
    let name: String
    let rating: Double
    let tagline: String
    let office: String
    let reviews: [Review]
}
