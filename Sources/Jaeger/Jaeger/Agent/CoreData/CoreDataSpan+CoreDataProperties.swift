//
//  CoreDataSpan+CoreDataProperties.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 11/6/18.
//
//

import Foundation
import CoreData

extension CoreDataSpan {

    /// Auto-generated function to get a specialized fetch request.
    @nonobjc class func fetchRequest() -> NSFetchRequest<CoreDataSpan> {
        return NSFetchRequest<CoreDataSpan>(entityName: "CoreDataSpan")
    }

    /// Binary representation of the span.
    @NSManaged var jsonSpan: NSData
    /// Start time of the stored span.
    @NSManaged var startTime: NSDate

}
