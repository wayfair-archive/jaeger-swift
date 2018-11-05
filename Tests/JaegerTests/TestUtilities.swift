//
//  TestUtilities.swift
//  JaegerTests
//
//  Created by Simon-Pierre Roy on 10/30/18.
//

import XCTest
@testable import Jaeger

/**
Useful and reusable constants to help the construction of new tests.
 */
enum TestUtilitiesConstants {
    /// Fixed UUID for a `Span`
    static let spanUUID = UUID(uuidString: "271C452F-D78A-4612-9425-79BCC21B3811")!
    /// Fixed UUID for a `Trace`
    static let traceUUID = UUID(uuidString: "54186C03-8F55-403F-97D0-CF602CE3D903")!
}

/**
 A stub Tracer.
 
Useful to test Spans when reporting can be ignored. **Do not use** the `startSpan` function.
 */
class EmptyTestTracer: Tracer {
    /// **Do not use**
    func startSpan(operationName: String, references: Span.Reference?, startTime: Date, tags: [Tag]) -> OTSpan {
        fatalError()
    }
    
    /// It does nothing.
    func report(span: Span) { }
}

/**
 A mock Tracer.
 
 Useful to test Spans when the result of the report function is needed. **Do not use** the `startSpan` function.
 */
class CompletionTestTracer: Tracer {
    
    private let reportedSpanCompletion: (Span) -> Void
    
    /**
     A Mock Tracer.
     
     - Parameter reportedSpanCompletion: A completion called every time a span is reported.
     - Parameter span: The reported span.

     */
    init(reportedSpanCompletion: @escaping (_ span: Span) -> Void) {
        self.reportedSpanCompletion = reportedSpanCompletion
    }
    
    /// **Do not use**
    func startSpan(operationName: String, references: Span.Reference?, startTime: Date, tags: [Tag]) -> OTSpan {
        fatalError()
    }
    
    /**
     Will call the `reportedSpanCompletion` block.
     */
    func report(span: Span) {
        reportedSpanCompletion(span)
    }
}

class TestUtilities {
    
    private init() {} // Only static methods for the class.
    
    /**
     A span constructor with default parameters for all fields.
     
     Useful to test Spans when the result of the report function is needed.
     
     - Parameter name: Default is \"testSpan\".
     - Parameter parentUUID:Default is `nil`.
     - Parameter startTime: Default is `Date()`.
     - Parameter spanUUID:  Default is `TestUtilitiesConstants.spanUUID`.
     - Parameter traceUUID: Default is `TestUtilitiesConstants.traceUUID`.
     - Parameter tracer: Default is `EmptyTestTracer`.
     - Parameter logs: Default is `[]`.
     - Parameter tags: Default is `[:]`.
     - Parameter references: Default is `[]`.

     */
    static func getNewTestSpan(name: String = "testSpan",
                            parentUUID: UUID? = nil,
                            startTime: Date = Date(),
                            spanUUID: UUID = TestUtilitiesConstants.spanUUID,
                            traceUUID: UUID = TestUtilitiesConstants.traceUUID,
                            tracer: Tracer = EmptyTestTracer(),
                            logs: [Log] = [],
                            tags: [Tag.Key : Tag] = [:],
                            references: [Span.Reference] = []) -> Span {
        
        return Span(tracer: tracer,
                    spanRef: Span.Context(traceId: traceUUID, spanId: spanUUID),
                    parentSpanId: parentUUID,
                    operationName: name,
                    references: references,
                    flag: .debug,
                    startTime: startTime,
                    tags: tags,
                    logs: logs)
    }
}




