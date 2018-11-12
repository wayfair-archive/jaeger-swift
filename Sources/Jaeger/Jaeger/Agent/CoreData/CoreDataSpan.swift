//
//  CoreDataSpan+CoreDataClass.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 11/6/18.
//
//

import Foundation
import CoreData

/// Auto-generated class to represent a `CoreDataSpan`.
@objc(CoreDataSpan)
class CoreDataSpan: NSManagedObject {

    /// Binary representation of the span.
    @NSManaged var jsonSpan: NSData
    /// Start time of the stored span.
    @NSManaged var startTime: NSDate

    /**
     Creates and adds a new `CoreDataSpan` in a given `NSManagedObjectContext`.
     
     - Parameter context: The context to which the span will be added.
     - Parameter startTime: The start time of the span.
     - Parameter data: The binary representation of the span.
     - Returns: A new `CoreDataSpan` inserted in the given `NSManagedObjectContext`.
     */
    @discardableResult
    static func create(in context: NSManagedObjectContext, startTime: Date, data: Data) -> CoreDataSpan {
        guard let entity = NSEntityDescription.entity(forEntityName: "CoreDataSpan", in: context) else {
            fatalError("Entity CoreDataSpan does not exist in the NSManagedObjectContext!")
        }

        let span = CoreDataSpan(entity: entity, insertInto: context)
        span.startTime = startTime as NSDate
        span.jsonSpan = data as NSData
        return span
    }

    /// Auto-generated function to get a specialized fetch request.
    @nonobjc class func fetchRequest() -> NSFetchRequest<CoreDataSpan> {
        return NSFetchRequest<CoreDataSpan>(entityName: "CoreDataSpan")
    }
}
