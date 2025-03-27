//
//  TakeoutEntity+CoreDataProperties.swift
//  govuk_review_app
//
//  Created by Syed.Ahmad on 27/03/2025.
//
//

import Foundation
import CoreData


extension TakeoutEntity: Identifiable {

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
    @NSManaged public var imageDataTransformable: Data?
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

extension TakeoutEntity {
    var imageDataArray: [Data] {
        get {
            guard let data = imageDataTransformable else { return [] }
            do {
                // Use Codable approach instead of NSKeyedUnarchiver
                return try JSONDecoder().decode([Data].self, from: data)
            } catch {
                print("Error decoding image data: \(error)")
                return []
            }
        }
        set {
            do {
                // Use Codable approach for encoding
                let encodedData = try JSONEncoder().encode(newValue)
                imageDataTransformable = encodedData
            } catch {
                print("Error encoding image data: \(error)")
                imageDataTransformable = nil
            }
        }
    }
}
