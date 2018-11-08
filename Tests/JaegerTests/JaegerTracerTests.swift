//
//  JaegerTracerTests.swift
//  JaegerTests
//
//  Created by Simon-Pierre Roy on 11/7/18.
//

import XCTest
@testable import Jaeger
import CoreData

class JaegerTracerTests: XCTestCase {
    
    private var coreDataStack: CoreDataStack!
    
    override func setUp() {
        coreDataStack = newCDStack()
    }
    
    private func newCDStack() -> CoreDataStack {
        let stack = CoreDataStack(
            modelName: TestUtilities.Constants.coreDataAgentModelName,
            model: TestUtilities.modelForCoreDataAgent,
            type: .inMemory
        )
        
        return stack
    }
    
    func testCreateSpan() {
        // Setup
        let reachability = TestReachabilityTracker(reachability: true)
        let sender = TestSender { _ in }
        
        guard let CDAgentConfig = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 1,
            sendingInterval: 2,
            coreDataFolderURL: nil
            ) else {
                return XCTFail()
        }
        
        let agent = CDAgent<JaegerSpan>(
            config: CDAgentConfig,
            sender: sender,
            stack: coreDataStack,
            reachabilityTracker: reachability
        )
        
        // TEST
        let tracer = JaegerTracer(agent: agent)
        let otSpan = tracer.startRootSpan(operationName: "TESTSPANNAME")
        var span: Span? = nil
        let getSpanExpectation = XCTestExpectation(description: "get Span")
        
        otSpan.get { getSpan in
            span = getSpan
            getSpanExpectation.fulfill()
        }
        
        wait(for: [getSpanExpectation], timeout: 0.5)
        
        guard let finalSpan = span else {
            return XCTFail()
        }
        
        XCTAssertEqual(finalSpan.operationName, "TESTSPANNAME")
        print(finalSpan.startTime.timeIntervalSince(Date()))
        XCTAssertLessThan(Date().timeIntervalSince(finalSpan.startTime), 0.5)
        XCTAssertEqual(finalSpan.isCompleted, false)
        XCTAssertEqual(finalSpan.flag, .sampled)
        XCTAssertEqual(finalSpan.spanRef.traceId, tracer.tracerId)
    }
    
    func testReportSpan() {
        
        // Setup
        let reachability = TestReachabilityTracker(reachability: true)
        
        let spansSent = XCTestExpectation(description: "Agent sent spans")
        var sentSpans: [JaegerSpan] = []
        let sender = TestSender { spans in
            
            guard let sentJaegerSpans = spans as? [JaegerSpan] else {
                XCTFail()
                spansSent.fulfill()
                return
            }
            sentSpans = sentJaegerSpans
            spansSent.fulfill()
        }
        
        guard let CDAgentConfig = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 0.05,
            sendingInterval: 0.1,
            coreDataFolderURL: nil) else {
                return XCTFail()
        }
        
        let agent = CDAgent<JaegerSpan>(
            config: CDAgentConfig,
            sender: sender,
            stack: coreDataStack,
            reachabilityTracker: reachability
        )
        
        // TEST
        let tracer = JaegerTracer(agent: agent)
        let span = tracer.startRootSpan(operationName: "TESTSPANNAME")
        span.finish()
        
        wait(for: [spansSent], timeout: 1)
        XCTAssertEqual(sentSpans.count, 1)
        XCTAssertEqual(sentSpans.first?.operationName, "TESTSPANNAME")
    }
}