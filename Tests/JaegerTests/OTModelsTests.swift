//
//  OTModelsTests.swift
//  JaegerTests
//
//  Created by Aaron Sky on 10/23/18.
//

import XCTest
@testable import Jaeger

class OTModelsTests: XCTestCase {
    
    
    override func setUp() { }

    override func tearDown() { }
    
    func testEndSpan() {
        var span = TestUtilities.getNewTestSpan()
        XCTAssertFalse(span.isCompleted)
        span.finish()
        XCTAssertTrue(span.isCompleted)
        XCTAssertNotNil(span.endTime)
    }
    
    func testSpanMultipleFinish() {
        let endDate = Date()
        var span = TestUtilities.getNewTestSpan()
        
        XCTAssertFalse(span.isCompleted)
        XCTAssertNil(span.endTime)
        
        span.finish(at: endDate)
        
        XCTAssertTrue(span.isCompleted)
        XCTAssertEqual(span.endTime, endDate)
        
        let newEndDate = Date()
        span.finish(at: newEndDate)
        XCTAssertTrue(span.isCompleted)
        XCTAssertEqual(span.endTime, endDate)
        XCTAssertNotEqual(span.endTime, newEndDate)
    }
    
    func testReplaceTagInSpan() {
        var span = TestUtilities.getNewTestSpan()
        let newTag = Tag(key: "testKey", tagType: .double(42))
        span.set(tag: newTag)
        
        let firstTag = span.tags["testKey"]
        XCTAssertNotNil(firstTag)
        XCTAssertEqual(firstTag, newTag)
        
        let replacingTag = Tag(key: "testKey", tagType: .bool(true))
        span.set(tag: replacingTag)
        
        let replacedTag = span.tags["testKey"]
        XCTAssertNotNil(replacedTag)
        XCTAssertEqual(replacedTag, replacingTag)
    }
    
    func testSaveSpanTagWhenSpanNotCompleted() {
        var span = TestUtilities.getNewTestSpan()
        let newTag = Tag(key: "testKey", tagType: .double(42))
        span.set(tag: newTag)
        
        let firstTag = span.tags["testKey"]
        XCTAssertNotNil(firstTag)
        XCTAssertEqual(firstTag, newTag)
    }
    
    func testSaveSpanTagWhenSpanCompleted() {
        var span = TestUtilities.getNewTestSpan()
        span.finish()
        let newTag = Tag(key: "testKey", tagType: .double(42))
        span.set(tag: newTag)
        XCTAssertTrue(span.tags.isEmpty)
    }
    
    func testSaveLogTagWhenSpanNotCompleted() {
        var span = TestUtilities.getNewTestSpan()
        let newTag = Tag(key: "testKey", tagType: .double(42))
        let newLog = Log(fields: [newTag])
        span.log(newLog)
        
        let firstLog = span.logs.first
        XCTAssertNotNil(firstLog)
        XCTAssertEqual(firstLog, newLog)
    }
    
    func testSaveLogTagWhenSpanCompleted() {
        var span = TestUtilities.getNewTestSpan()
        span.finish()
        let newTag = Tag(key: "testKey", tagType: .double(42))
        let newLog = Log(fields: [newTag])
        span.log(newLog)
        XCTAssertTrue(span.logs.isEmpty)
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
}
