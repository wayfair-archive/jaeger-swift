//
//  OTModelsTests.swift
//  JaegerTests
//
//  Created by Aaron Sky on 10/23/18.
//

import XCTest
@testable import Jaeger

class OTModelsTests: XCTestCase {

    var defaultSpan = TestUtilities.getNewTestSpan()

    override func setUp() {
        defaultSpan = TestUtilities.getNewTestSpan()
    }

    func testEndSpan() {
        XCTAssertFalse(defaultSpan.isCompleted)
        defaultSpan.finish()
        XCTAssertTrue(defaultSpan.isCompleted)
        XCTAssertNotNil(defaultSpan.endTime)
    }

    func testSpanMultipleFinish() {
        let endDate = Date()

        XCTAssertFalse(defaultSpan.isCompleted)
        XCTAssertNil(defaultSpan.endTime)

        defaultSpan.finish(at: endDate)

        XCTAssertTrue(defaultSpan.isCompleted)
        XCTAssertEqual(defaultSpan.endTime, endDate)

        let newEndDate = Date()
        defaultSpan.finish(at: newEndDate)
        XCTAssertTrue(defaultSpan.isCompleted)
        XCTAssertEqual(defaultSpan.endTime, endDate)
        XCTAssertNotEqual(defaultSpan.endTime, newEndDate)
    }

    func testReplaceTagInSpan() {
        let newTag = Tag(key: "testKey", tagType: .double(42))
        defaultSpan.set(tag: newTag)

        let firstTag = defaultSpan.tags["testKey"]
        XCTAssertNotNil(firstTag)
        XCTAssertEqual(firstTag, newTag)

        let replacingTag = Tag(key: "testKey", tagType: .bool(true))
        defaultSpan.set(tag: replacingTag)

        let replacedTag = defaultSpan.tags["testKey"]
        XCTAssertNotNil(replacedTag)
        XCTAssertEqual(replacedTag, replacingTag)
    }

    func testSaveSpanTagWhenSpanNotCompleted() {
        let newTag = Tag(key: "testKey", tagType: .double(42))
        defaultSpan.set(tag: newTag)

        let firstTag = defaultSpan.tags["testKey"]
        XCTAssertNotNil(firstTag)
        XCTAssertEqual(firstTag, newTag)
    }

    func testSaveSpanTagWhenSpanCompleted() {
        defaultSpan.finish()
        let newTag = Tag(key: "testKey", tagType: .double(42))
        defaultSpan.set(tag: newTag)
        XCTAssertTrue(defaultSpan.tags.isEmpty)
    }

    func testSaveLogTagWhenSpanNotCompleted() {
        let newTag = Tag(key: "testKey", tagType: .double(42))
        let newLog = Log(fields: [newTag])
        defaultSpan.log(newLog)

        let firstLog = defaultSpan.logs.first
        XCTAssertNotNil(firstLog)
        XCTAssertEqual(firstLog, newLog)
    }

    func testSaveLogTagWhenSpanCompleted() {
        defaultSpan.finish()
        let newTag = Tag(key: "testKey", tagType: .double(42))
        let newLog = Log(fields: [newTag])
        defaultSpan.log(newLog)
        XCTAssertTrue(defaultSpan.logs.isEmpty)
    }

    func testOTSpanEnd() {
        let expectation = XCTestExpectation(description: "Tracer will receive the span")

        var tracerSpan: Span?
        let tracer = CompletionTestTracer { span in
            tracerSpan = span
            expectation.fulfill()
        }

        let span = TestUtilities.getNewTestSpan(tracer: tracer)

        let otSpan = OTSpan(span: span, synchronizingQueue: .main)
        let endDate = Date()
        otSpan.finish(at: endDate)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(tracerSpan?.endTime, endDate)
        XCTAssertEqual(tracerSpan, span)
    }

    func testOTSpanSet() {
        let expectation = XCTestExpectation(description: "Tracer will receive the span")

        var tracerSpan: Span?

        let tracer = CompletionTestTracer { span in
            tracerSpan = span
            expectation.fulfill()
        }

        let span = TestUtilities.getNewTestSpan(tracer: tracer)

        let otSpan = OTSpan(span: span)
        let newTag = Tag(key: "testKey", tagType: .double(42))

        otSpan.set { span in
            span.set(tag: newTag)
        }
        otSpan.finish()

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(tracerSpan?.tags["testKey"], newTag)
    }

    func testOTSpanGet() {
        let expectation = XCTestExpectation(description: "Read the span from OT Span")

        let span = TestUtilities.getNewTestSpan()

        let otSpan = OTSpan(span: span)
        let newTag = Tag(key: "testKey", tagType: .double(42))

        otSpan.set { span in
            span.set(tag: newTag)
        }

        var readSpan: Span?
        otSpan.get { span in
            readSpan = span
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(readSpan?.tags["testKey"], newTag)
    }

    func testParentSpanInit() {
        let tracer = EmptyTestTracer()
        let startTime = Date()
        let tag = Tag(key: "testKey", tagType: .string("testType"))
        let log = Log(timestamp: startTime, fields: [tag])
        let uuid = UUID()
        let name = "oppName"
        let context =  Span.Context(traceId: uuid, spanId: uuid)
        let parentRef = Span.Reference(refType: .childOf, context: context)

        let span = Span(
            tracer: tracer,
            spanRef: context,
            parentSpanRef: parentRef,
            operationName: name,
            flag: .debug,
            startTime: startTime,
            tags: [tag.key: tag],
            logs: [log]
        )

        XCTAssertEqual(span.parentSpanId, parentRef.context.spanId)
        XCTAssertEqual(span.references.first, parentRef)
        XCTAssertEqual(span.references.count, 1)
    }

    func testPerformanceSpanInit() {

        let tracer = EmptyTestTracer()
        let startTime = Date()
        let tag = Tag(key: "testKey", tagType: .string("testType"))
        let log = Log(timestamp: startTime, fields: [tag])
        let uuid = UUID()
        let name = "oppName"
        let context =  Span.Context(traceId: uuid, spanId: uuid)
        let parentRef = Span.Reference(refType: .childOf, context: context)

        self.measure {
            let span = Span(
                tracer: tracer,
                spanRef: context,
                parentSpanRef: parentRef,
                operationName: name,
                flag: .debug,
                startTime: startTime,
                tags: [tag.key: tag],
                logs: [log]
            )
            _ = span.endTime
        }
    }
}
