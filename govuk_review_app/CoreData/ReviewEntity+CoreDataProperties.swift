//
//  ReviewEntity+CoreDataProperties.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 20/03/2025.
//
//

import Foundation
import CoreData


extension ReviewEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReviewEntity> {
        return NSFetchRequest<ReviewEntity>(entityName: "ReviewEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var rating: Double
    @NSManaged public var reviewDescription: String?
    @NSManaged public var reviewerName: String?
    @NSManaged public var takeoutId: UUID?

}

extension ReviewEntity : Identifiable {

}
