//
//  Mocks.swift
//  JaegerTests
//
//  Created by Simon-Pierre Roy on 11/8/18.
//

import XCTest
@testable import Jaeger

/**
 A stub Tracer.
 
 Useful to test Spans when reporting can be ignored. **Do not use** the `startSpan` function.
 */
class EmptyTestTracer: Tracer {
    /// **Do not use**
    func startSpan(operationName: String, referencing reference: Span.Reference?, startTime: Date, tags: [Tag]) -> OTSpan {
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
    func startSpan(operationName: String, referencing reference: Span.Reference?, startTime: Date, tags: [Tag]) -> OTSpan {
        fatalError()
    }

    /**
     Will call the `reportedSpanCompletion` block.
     */
    func report(span: Span) {
        reportedSpanCompletion(span)
    }
}

/**
 A mock `SpanSender`.
 */
class TestSender: SpanSender {
    let sendingCompletion: ([SpanConvertible]) -> Void

    init(sendingCompletion: @escaping ([SpanConvertible]) -> Void) {
        self.sendingCompletion = sendingCompletion
    }
    func send<RawSpan>(spans: [RawSpan], completion: CompletionStatus?) where RawSpan: SpanConvertible {
        sendingCompletion(spans)
    }
}

/**
 A class that can be used to mock network status.
 */
class TestReachabilityTracker: ReachabilityTracker {

    var reachability: Bool

    init(reachability: Bool) {
        self.reachability = reachability
    }

    func isNetworkReachable() -> Bool {
        return reachability
    }

    func getStatus() -> ReachabilityStatus {
        return reachability ? .wifi: .notConnected
    }
}

/**
 A mock `SpanConvertible`.
 */
struct TestSpanConvertible: SpanConvertible {
    static func convert(span: Span) -> TestSpanConvertible {
        return TestSpanConvertible()
    }

    init() { }
    init(span: Span) { }
}

#if canImport(CoreData)
/**
 A mock `CDAgentErrorDelegate`.
 */
class TestCDAgentErrorDelegate: CoreDataAgentErrorDelegate {

    let errorCompletion: (Error) -> Void

    init(errorCompletion: @escaping (Error) -> Void) {
        self.errorCompletion = errorCompletion
    }

    func handleError(_ error: Error) {
        errorCompletion(error)
    }
}
#endif

/**
 A mock `SpanSender`.
 */
class EmptySender: SpanSender {
    func send<RawSpan>(spans: [RawSpan], completion: CompletionStatus?) where RawSpan: SpanConvertible {
        completion?(nil)
    }
}

/**
 A mock `Agent`.
 */
class EmptyAgent: Agent {
    var spanSender: SpanSender = EmptySender()

    func record(span: Span) { }
}
