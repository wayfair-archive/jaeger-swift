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
    
    /**
     Creates and adds a new `CoreDataSpan` in a given `NSManagedObjectContext`.
     
     - Parameter context: The context to which the span will be added.
     - Parameter startTime: The start time of the span.
     - Parameter data: The binary representation of the span.
     - Returns: A new `CoreDataSpan` inserted in the given `NSManagedObjectContext`.
     */
    @discardableResult
    static func insertNewSpan(in context: NSManagedObjectContext, startTime: Date, data: Data) -> CoreDataSpan {
        let entity = NSEntityDescription.entity(forEntityName: "CoreDataSpan", in: context)!
        let span = CoreDataSpan(entity: entity, insertInto: context)
        span.startTime = startTime as NSDate
        span.jsonSpan = data as NSData
        return span
    }
}