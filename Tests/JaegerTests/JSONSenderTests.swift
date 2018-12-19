//
//  JSONSenderTests.swift
//  JaegerTests
//
//  Created by Simon-Pierre Roy on 11/8/18.
//

import XCTest
@testable import Jaeger
import CoreData

class JSONSenderTests: XCTestCase {

    func testSendSpansNoError() {

        let urlTest = URL(string: "testURL")!
        let mockSession = URLSessionMock()
        let sender = JSONSender(endPoint: urlTest, session: mockSession)

        let spansSent = XCTestExpectation(description: "sender sent spans")

        let jaegerSpan = JaegerSpan(span: TestUtilities.getNewTestSpan())

        sender.send(spans: [jaegerSpan]) { error in
            XCTAssertNil(error)
            spansSent.fulfill()
        }

        wait(for: [spansSent], timeout: 1)
    }

    func testSendSpansWithError() {

        let urlTest = URL(string: "testURL")!
        let mockSession = URLSessionMock()
        let testError = NSError(domain: "testError", code: -1, userInfo: nil)

        mockSession.error = testError

        let sender = JSONSender(endPoint: urlTest, session: mockSession)

        let spansSent = XCTestExpectation(description: "sender sent spans")
        let jaegerSpan = JaegerSpan(span: TestUtilities.getNewTestSpan())

        sender.send(spans: [jaegerSpan]) { error in
            XCTAssertEqual((error as NSError?), testError)
            spansSent.fulfill()
        }

        wait(for: [spansSent], timeout: 1)
    }

    func testSendSpansJaegerNoError() {

        let urlTest = URL(string: "testURL")!
        let mockSession = URLSessionMock()

        let nameId = "test process"

        let tag = Tag(key: nameId, tagType: .bool(true))
        let testProcess = JaegerBatchProcess(serviceName: nameId, tags: [tag])
        let sender = JaegerJSONSender(endPoint: urlTest, process: testProcess, session: mockSession)

        let spansSent = XCTestExpectation(description: "sender sent spans")
        let sessionDone = XCTestExpectation(description: "session Done")
        let jaegerSpan = JaegerSpan(span: TestUtilities.getNewTestSpan(name: nameId ))

        mockSession.dataTaskExcuted = { resquest in
            guard let data = resquest.httpBody else { return XCTFail("Need Data") }
            guard let batch = try? JSONDecoder().decode(JaegerBatch.self, from: data)  else {
                return XCTFail("Wrong Data")
            }
            XCTAssertEqual(batch.process.serviceName, nameId)
            XCTAssertEqual(batch.process.tags?.first?.key, nameId)
            XCTAssertEqual(batch.spans.first?.operationName, nameId)
            spansSent.fulfill()
        }

        sender.send(spans: [jaegerSpan]) { _ in
            sessionDone.fulfill()
        }

        wait(for: [spansSent, sessionDone], timeout: 1)
    }

    func testSendSpansJaegerNoJaeger() {

        struct FakeSpan: SpanConvertible {

            static func convert(span: Span) -> FakeSpan {
                return FakeSpan()
            }

            let name: String

            init(name: String = "fakeName") {
                self.name = name
            }

            init(span: Span) { self.init() }
        }

        let urlTest = URL(string: "testURL")!
        let mockSession = URLSessionMock()

        let nameId = "test process"

        let tag = Tag(key: nameId, tagType: .bool(true))
        let testProcess = JaegerBatchProcess(serviceName: nameId, tags: [tag])
        let sender = JaegerJSONSender(endPoint: urlTest, process: testProcess, session: mockSession)

        let spansSent = XCTestExpectation(description: "sender sent spans")
        let sessionDone = XCTestExpectation(description: "session Done")
        let fakeSpan = FakeSpan()

        mockSession.dataTaskExcuted = { resquest in
            guard let data = resquest.httpBody else { return XCTFail("Need Data") }
            guard (try? JSONDecoder().decode([FakeSpan].self, from: data)) != nil else {
                return XCTFail("Wrong Data")
            }
            spansSent.fulfill()
        }

        sender.send(spans: [fakeSpan]) { _ in
            sessionDone.fulfill()
        }

        wait(for: [spansSent, sessionDone], timeout: 1)
    }

    func testSendSpans() {

        let urlTest = URL(string: "testURL")!
        let mockSession = URLSessionMock()
        let nameId = "test spans"
        let sender = JSONSender(endPoint: urlTest, session: mockSession)

        let spansSent = XCTestExpectation(description: "sender sent spans")
        let sessionDone = XCTestExpectation(description: "session Done")
        let jaegerSpan = JaegerSpan(span: TestUtilities.getNewTestSpan(name: nameId ))

        mockSession.dataTaskExcuted = { resquest in
            guard let data = resquest.httpBody else { return XCTFail("Need Data") }
            guard let spans = try? JSONDecoder().decode([JaegerSpan].self, from: data)  else {
                return XCTFail("Wrong Data")
            }
            XCTAssertEqual(spans.first?.operationName, nameId)
            spansSent.fulfill()
        }

        sender.send(spans: [jaegerSpan]) { _ in
            sessionDone.fulfill()
        }

        wait(for: [spansSent, sessionDone], timeout: 1)
    }
}
