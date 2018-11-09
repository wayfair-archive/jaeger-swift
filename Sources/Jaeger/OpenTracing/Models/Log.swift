//
//  Log.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/29/18.
//

import Foundation

/**
 An event that occurred at a specific point in time with the information stored as **key:value** pairs.
 */
public struct Log: Equatable {

    /**
     Creates a new tag from a log event.
     
     - Parameter timestamp: The date at which the event occurred.
     - Parameter fields: The information associated with the event.
     */
    public init(timestamp: Date = Date(), fields: [Tag]) {
        self.timestamp = timestamp
        self.fields  = fields
    }

    /// The time at which the event occurred.
    public let timestamp: Date
    /// The information associated with the event.
    public let fields: [Tag]
}
