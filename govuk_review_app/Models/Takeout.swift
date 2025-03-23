//
//  Takeout.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 28/01/2025.
//

import Foundation

struct Takeout: Identifiable, Decodable {
    let id = UUID()
    let name: String
    let rating: Double
    let office: String
//    let latitude: Double
//    let longitude: Double
    let tagline: String?

    var localImageNames: [String] {
        let baseName = name.replacingOccurrences(of: " ", with: "_").lowercased()
        return (1...3).map { "\(baseName)_\($0)" }  // Adjust the range as needed
    }
}
