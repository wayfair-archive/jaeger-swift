//
//  CoreDataAgentTests.swift
//  JaegerTests
//
//  Created by Simon-Pierre Roy on 11/6/18.
//

import XCTest
import CoreData
@testable import Jaeger

// swiftlint:disable type_body_length
class CoreDataAgentTests: XCTestCase {

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

    func testReportWithLimitPerSecondSpansWithReachability() {

        let reachability = TestReachabilityTracker(reachability: true)
        let sender = TestSender { _ in }
        let maxPerSec: Int = 2

        guard let CDAgentConfig = CDAgentConfiguration(
            averageMaximumSpansPerSecond: maxPerSec,
            savingInterval: 1,
            sendingInterval: 2,
            coreDataFolderURL: nil) else {
                return XCTFail("Invalid CDAgentConfig")
        }

        let agent = CDAgent<TestSpanConvertible>(
            config: CDAgentConfig,
            sender: sender,
            stack: coreDataStack,
            reachabilityTracker: reachability
        )

        agent.record(span: TestUtilities.getNewTestSpan())
        agent.record(span: TestUtilities.getNewTestSpan())
        agent.record(span: TestUtilities.getNewTestSpan())
        agent.record(span: TestUtilities.getNewTestSpan())

        coreDataStack.defaultBackgroundContext.performAndWait { [weak coreDataStack] in
            let count = try? coreDataStack?.defaultBackgroundContext.count(for: CoreDataSpan.fetchRequest())
            XCTAssertEqual(count, maxPerSec)
        }
    }

    func testSendAndDeleteSpansWithReachability() {

        let reachability = TestReachabilityTracker(reachability: true)
        let spansSent = XCTestExpectation(description: "Agent sent spans")

        let sender = TestSender { spans in
            XCTAssertEqual(spans.count, 1)
            spansSent.fulfill()
        }

        guard let CDAgentConfig = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 0.1,
            sendingInterval: 0.2,
            coreDataFolderURL: nil) else {
                return XCTFail("Invalid CDAgentConfig")
        }

        let agent = CDAgent<TestSpanConvertible>(
            config: CDAgentConfig,
            sender: sender,
            stack: coreDataStack,
            reachabilityTracker: reachability
        )

        agent.record(span: TestUtilities.getNewTestSpan())
        agent.record(span: TestUtilities.getNewTestSpan())

        wait(for: [spansSent], timeout: 1)

        coreDataStack.defaultBackgroundContext.performAndWait { [weak coreDataStack] in
            let count = try? coreDataStack?.defaultBackgroundContext.count(for: CoreDataSpan.fetchRequest())
            XCTAssertEqual(count, 0)
        }
    }

    func testKeepSpansIfNoReachability() {

        let reachability = TestReachabilityTracker(reachability: false)
        let spansSent = XCTestExpectation(description: "Agent sent spans")
        let sender = TestSender { _ in }

        guard let CDAgentConfig = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 0.1,
            sendingInterval: 0.15,
            coreDataFolderURL: nil) else {
                return XCTFail("Invalid CDAgentConfig")
        }

        let agent = CDAgent<TestSpanConvertible>(
            config: CDAgentConfig,
            sender: sender,
            stack: coreDataStack,
            reachabilityTracker: reachability
        )

        agent.record(span: TestUtilities.getNewTestSpan())

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            spansSent.fulfill()
        }

        wait(for: [spansSent], timeout: 1)

        coreDataStack.defaultBackgroundContext.performAndWait { [weak coreDataStack] in
            let count = try? coreDataStack?.defaultBackgroundContext.count(for: CoreDataSpan.fetchRequest())
            XCTAssertEqual(count, 1)
        }
    }

    func testChangeNoNetworkToNetwork() {

        let reachability = TestReachabilityTracker(reachability: false)
        let spansSent = XCTestExpectation(description: "Agent sent spans")
        let spansNotSent = XCTestExpectation(description: "Agent did not send spans")

        let sender = TestSender { spans in
            XCTAssertEqual(spans.count, 1)
            spansSent.fulfill()
        }

        guard let CDAgentConfig = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 0.1,
            sendingInterval: 0.15,
            coreDataFolderURL: nil) else {
                return XCTFail("Invalid CDAgentConfig")
        }

        let agent = CDAgent<TestSpanConvertible>(
            config: CDAgentConfig,
            sender: sender,
            stack: coreDataStack,
            reachabilityTracker: reachability
        )

        agent.record(span: TestUtilities.getNewTestSpan())

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            reachability.reachability = true
            spansNotSent.fulfill()
        }

        wait(for: [spansNotSent], timeout: 1)

        coreDataStack.defaultBackgroundContext.performAndWait { [weak coreDataStack] in
            let count = try? coreDataStack?.defaultBackgroundContext.count(for: CoreDataSpan.fetchRequest())
            XCTAssertEqual(count, 1)
        }

        wait(for: [spansSent], timeout: 1)

        coreDataStack.defaultBackgroundContext.performAndWait { [weak coreDataStack] in
            let count = try? coreDataStack?.defaultBackgroundContext.count(for: CoreDataSpan.fetchRequest())
            XCTAssertEqual(count, 0)
        }
    }

    func testChangeNetworkToNoNetwork() {

        let reachability = TestReachabilityTracker(reachability: true)
        let spansSent = XCTestExpectation(description: "Agent sent spans")
        let spansNotSent = XCTestExpectation(description: "Agent did not send spans")

        let sender = TestSender { spans in
            XCTAssertEqual(spans.count, 1)
            reachability.reachability = false
            spansSent.fulfill()
        }

        guard let CDAgentConfig = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 0.1,
            sendingInterval: 0.15,
            coreDataFolderURL: nil) else {
                return XCTFail("Invalid CDAgentConfig")
        }

        let agent = CDAgent<TestSpanConvertible>(
            config: CDAgentConfig,
            sender: sender,
            stack: coreDataStack,
            reachabilityTracker: reachability
        )

        agent.record(span: TestUtilities.getNewTestSpan())

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            spansNotSent.fulfill()
        }

        wait(for: [spansSent], timeout: 1)
        agent.record(span: TestUtilities.getNewTestSpan())
        wait(for: [spansNotSent], timeout: 1)

        coreDataStack.defaultBackgroundContext.performAndWait { [weak coreDataStack] in
            let count = try? coreDataStack?.defaultBackgroundContext.count(for: CoreDataSpan.fetchRequest())
            XCTAssertEqual(count, 1)
        }
    }

    func testAgentNetworkError() {

        let reachability = TestReachabilityTracker(reachability: true)
        let errorSender = XCTestExpectation(description: "error when sending spans")

        let urlTest = URL(string: "testURL")!
        let mockSession = URLSessionMock()
        let testError = NSError(domain: "testError", code: -1, userInfo: nil)

        mockSession.error = testError

        let sender = JSONSender(endPoint: urlTest, session: mockSession)

        let errorDelegate = TestCDAgentErrorDelegate { error in
            XCTAssertEqual(error as NSError, testError)
            errorSender.fulfill()
        }

        guard let CDAgentConfig = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 0.1,
            sendingInterval: 0.15,
            errorDelegate: errorDelegate,
            coreDataFolderURL: nil) else {
                return XCTFail("Invalid CDAgentConfig")
        }

        let agent = CDAgent<TestSpanConvertible>(
            config: CDAgentConfig,
            sender: sender,
            stack: coreDataStack,
            reachabilityTracker: reachability
        )

        agent.record(span: TestUtilities.getNewTestSpan())

        wait(for: [errorSender], timeout: 1)
    }

    func testCDAgentConfigSpansPerSecond() {

        let configNegative = CDAgentConfiguration(
            averageMaximumSpansPerSecond: -1,
            savingInterval: 1,
            sendingInterval: 2,
            coreDataFolderURL: nil
        )

        let configZero = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 0,
            savingInterval: 1,
            sendingInterval: 2,
            coreDataFolderURL: nil
        )

        let configPositive = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 1,
            sendingInterval: 2,
            coreDataFolderURL: nil
        )

        XCTAssertNil(configNegative)
        XCTAssertNil(configZero)
        XCTAssertNotNil(configPositive)
    }

    func testCDAgentConfigSavingInterval() {

        let configNegative = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: -1,
            sendingInterval: 2,
            coreDataFolderURL: nil
        )

        let configZero = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 0,
            sendingInterval: 2,
            coreDataFolderURL: nil
        )

        let configPositive = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 1,
            sendingInterval: 2,
            coreDataFolderURL: nil
        )

        XCTAssertNil(configNegative)
        XCTAssertNil(configZero)
        XCTAssertNotNil(configPositive)
    }

    func testCDAgentConfigSendingInterval() {

        let configNegative = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 1,
            sendingInterval: -2,
            coreDataFolderURL: nil
        )

        let configZero = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 1,
            sendingInterval: 0,
            coreDataFolderURL: nil
        )

        let configPositive = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 1,
            sendingInterval: 2,
            coreDataFolderURL: nil
        )

        XCTAssertNil(configNegative)
        XCTAssertNil(configZero)
        XCTAssertNotNil(configPositive)
    }

    func testCDAgentConfigSavingSendingFrequencyInterval() {

        let configSavingMorefrequentThanSending = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 2,
            sendingInterval: 4,
            coreDataFolderURL: nil
        )

        let configSendingMorefrequentThanSaving = CDAgentConfiguration(
            averageMaximumSpansPerSecond: 1,
            savingInterval: 4,
            sendingInterval: 2,
            coreDataFolderURL: nil
        )

        XCTAssertNotNil(configSavingMorefrequentThanSending)
        XCTAssertNil(configSendingMorefrequentThanSaving)
    }
}
