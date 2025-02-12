//
//  TakeoutEntity+CoreDataProperties.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 12/02/2025.
//
//

import Foundation
import CoreData


extension TakeoutEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TakeoutEntity> {
        return NSFetchRequest<TakeoutEntity>(entityName: "TakeoutEntity")
    }

    @NSManaged public var id: UUID?
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
