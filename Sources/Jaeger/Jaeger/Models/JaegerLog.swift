//
//  JaegerLog.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/29/18.
//

import Foundation

/**
 The Jaeger version of an OpenTracing Log.
 
 See the [Jaeger.Thrift](https://github.com/jaegertracing/jaeger-idl/blob/master/thrift/jaeger.thrift) definition.
 */
struct JaegerLog: Codable {

    /**
     Creates a Jaeger Log from an OpenTracing Log.
     
     - Parameter log: An OpenTracing Log.
     */
    init(log: Log) {
        // usually unsafe, but it is OK when the timeIntervalSince1970 is expressed in microseconds, since this number will be smaller than Int64.max.
        timestamp = Int64(log.timestamp.timeIntervalSince1970.microseconds)
        fields = log.fields.map { JaegerTag(tag: $0) }
    }

    /// The time at which the event occurred with Unix time in microseconds.
    let timestamp: Int64
    /// An arbitrary set of tags.
    let fields: [JaegerTag]
}
