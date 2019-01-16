//
//  JaegerSpan.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/29/18.
//

import Foundation

/**
 The Jaeger version of an OpenTracing Span.
 
 See the [Jaeger.Thrift](https://github.com/jaegertracing/jaeger-idl/blob/master/thrift/jaeger.thrift) definition.
 */
public struct JaegerSpan: SpanConvertible {

    /**
     Creates a Jaeger Span from an OpenTracing Span.
     
     - Parameter span: An OpenTracing Span.
     */
    public static func convert(span: Span) -> JaegerSpan {
        return JaegerSpan(span: span)
    }

    /**
     Creates a Jaeger Span from an OpenTracing Span.
     
     - Parameter span: An OpenTracing Span.
     */
    public init(span: Span) {
        /* When splitting the UUID in two parts, we guarantee that the server will combine them again to recreate the same and
         valid UUID as per RFC 4122 version */
        traceIdLow = Int64(bitPattern: span.spanRef.traceId.firstHalfBits) // split the uuid in two parts!
        traceIdHigh = Int64(bitPattern: span.spanRef.traceId.secondHalfBits) // split the uuid in two parts!
        // When using the most significant bits, we are not creating a valid UUID. But this number is random enough for our use case.
        spanId = Int64(bitPattern: span.spanRef.spanId.firstHalfBits) // generates an almost random new id from a UUID, see doc for firstHalfBits!

        if let parentSpanId = span.parentSpanId {
            // When using the most significant bits, we are not creating a valid UUID. But this number is random enough for our use case.
            self.parentSpanId = Int64(bitPattern: parentSpanId.firstHalfBits)  // generates an almost random new id from a UUID, see doc for firstHalfBits!
        } else { // root span
            self.parentSpanId = 0
        }

        operationName = span.operationName
        references = span.references.map { JaegerSpanReference(ref: $0) }
        // usually unsafe, but it is OK when the timeIntervalSince1970 is expressed in microseconds, since this number will be smaller than Int64.max.
        startTime = Int64(span.startTime.timeIntervalSince1970.microseconds)
        tags = Array(span.tags.values).map { JaegerTag(tag: $0) }
        logs = span.logs.map { JaegerLog(log: $0) }
        incomplete = !span.isCompleted
        // usually unsafe, but it is OK when the timeIntervalSince1970 is expressed in microseconds, since this number will be smaller than Int64.max.
        duration = Int64(span.endTime?.timeIntervalSince(span.startTime).microseconds ?? 0)

        switch span.flag {
        case .debug: flags = 2
        case .sampled: flags = 1
        }
    }

    /**
     The Jaeger version of an OpenTracing Span Reference.
     
     See the [Jaeger.Thrift](https://github.com/jaegertracing/jaeger-idl/blob/master/thrift/jaeger.thrift) definition.
     */
    struct JaegerSpanReference: Codable { // Jaeger.Thrift original def

        /**
         Creates a Jaeger Span Reference from an OpenTracing Span Reference.
         
         - Parameter ref: An OpenTracing Span Reference.
         */
        init(ref: Span.Reference) {
            // When using the most significant bits, we are not creating a valid UUID. But this number is random enough for our use case.
            spanId = Int64(bitPattern: ref.context.spanId.firstHalfBits) // generates an almost random new id from a UUID, see doc for firstHalfBits!
            /* When splitting the UUID in two parts, we guarantee that the server will combine them again to recreate the same and
             valid UUID as per RFC 4122 version */
            traceIdLow = Int64(bitPattern: ref.context.traceId.firstHalfBits) // split the uuid in two parts!
            traceIdHigh = Int64(bitPattern: ref.context.traceId.secondHalfBits) // split the uuid in two parts!

            switch ref.refType {
            case .childOf:
                refType = .childOf
            case .followsFrom:
                refType = .followsFrom
            }
        }

        /**
         The Jaeger version of an OpenTracing Span Reference Type.
         
         See the [Jaeger.Thrift](https://github.com/jaegertracing/jaeger-idl/blob/master/thrift/jaeger.thrift) definition.
         */
        enum RefType: String, Codable { // Jaeger.Thrift original def
            /// A span that depends on a child Span in some capacity.
            case childOf = "CHILD_OF"
            /// A span that does not depend in any way on the result of a child.
            case followsFrom = "FOLLOWS_FROM"
        }

        /// The relationship to the span.
        let refType: JaegerSpanReference.RefType
        /// The least significant 64 bits of a traceid.
        let traceIdLow: Int64
        /// The most significant 64 bits of a traceid. **Set this to 0 when only using 64bit ids.**
        let traceIdHigh: Int64
        /// The span id. Make certain that there is a low risk of collision when producing the id.
        let spanId: Int64
    }

    /// The least significant 64 bits of a traceid.
    let traceIdLow: Int64
    /// The most significant 64 bits of a traceid. **Set this to 0 when only using 64bit ids.**
    let traceIdHigh: Int64
    /// The span id. Make certain that there is a low risk of collision when producing the id.
    let spanId: Int64
    /// The parent node id. Make certain that there is a low risk of collision when producing the id.
    let parentSpanId: Int64
    /// A human-readable string which concisely represents the work done by the span.
    let operationName: String
    /// The list of references to other nodes.
    let references: [JaegerSpanReference]?
    /// A flag to identify whether a flag is in a debug state:  1 signifies a SAMPLED span and 2 signifies a DEBUG span.
    let flags: Int32
    ///  The time at which the task started.
    let startTime: Int64
    ///  The time, in microseconds, taken to execute the task.
    let duration: Int64
    ///  The tags set before the completion the span.
    let tags: [JaegerTag]?
    /// The logged events that occurrence before the completion the span.
    let logs: [JaegerLog]?
    /// A boolean indicating if the task is incomplete.
    let incomplete: Bool?
}
