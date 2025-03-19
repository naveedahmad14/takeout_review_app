//
//  TakeoutEntity+CoreDataProperties.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 19/03/2025.
//
//

import Foundation
import CoreData


extension TakeoutEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TakeoutEntity> {
        return NSFetchRequest<TakeoutEntity>(entityName: "TakeoutEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var latitude: NSDecimalNumber?
    @NSManaged public var longitude: NSDecimalNumber?
    @NSManaged public var name: String?
    @NSManaged public var office: String?
    @NSManaged public var rating: Double
    @NSManaged public var tagline: String?
    @NSManaged public var reviews: NSSet?

}

// MARK: Generated accessors for reviews
extension TakeoutEntity {

    @objc(addReviewsObject:)
    @NSManaged public func addToReviews(_ value: ReviewEntity)

    @objc(removeReviewsObject:)
    @NSManaged public func removeFromReviews(_ value: ReviewEntity)

    @objc(addReviews:)
    @NSManaged public func addToReviews(_ values: NSSet)

    @objc(removeReviews:)
    @NSManaged public func removeFromReviews(_ values: NSSet)

}

extension TakeoutEntity : Identifiable {

}

extension TakeoutEntity {
    var localImageNames: [String] {
        guard let name = name else { return ["default_image"] }
        let baseName = name.replacingOccurrences(of: " ", with: "_").lowercased()

        // Assuming you have multiple images indexed like name_1, name_2, etc.
        return (1...3).map { "\(baseName)_\($0)" }  // Adjust the range as needed
    }

    /*
    // API Image Support (Commented Out for Later)
    var imageUrlsArray: [String] {
        (images as? [String]) ?? []
    }
    */
}
