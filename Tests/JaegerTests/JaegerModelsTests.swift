//
//  JaegerModelsTests.swift
//  JaegerTests
//
//  Created by Simon-Pierre Roy on 10/30/18.
//

import XCTest
@testable import Jaeger

class JaegerModelsTests: XCTestCase {
    
    func testJaegerTagConversionString() {
        let tag = Tag(key: "testKey", tagType: .string("testType"))
        let jaegerTag = JaegerTag(tag: tag)
        XCTAssertEqual(jaegerTag.key, "testKey")
        XCTAssertEqual(jaegerTag.vStr, "testType")
        XCTAssertNil(jaegerTag.vBool)
        XCTAssertNil(jaegerTag.vLong)
        XCTAssertNil(jaegerTag.vBinary)
        XCTAssertNil(jaegerTag.vDouble)
        XCTAssertEqual(jaegerTag.vType, .string)
    }
    
    func testJaegerTagConversionBool() {
        let tag = Tag(key: "testKey", tagType: .bool(false))
        let jaegerTag = JaegerTag(tag: tag)
        XCTAssertEqual(jaegerTag.key, "testKey")
        XCTAssertNil(jaegerTag.vStr)
        XCTAssertEqual(jaegerTag.vBool, false)
        XCTAssertNil(jaegerTag.vLong)
        XCTAssertNil(jaegerTag.vBinary)
        XCTAssertNil(jaegerTag.vDouble)
        XCTAssertEqual(jaegerTag.vType, .bool)
    }
    
    func testJaegerTagConversionLong() {
        let tag = Tag(key: "testKey", tagType: .int64(42))
        let jaegerTag = JaegerTag(tag: tag)
        XCTAssertEqual(jaegerTag.key, "testKey")
        XCTAssertNil(jaegerTag.vStr)
        XCTAssertNil(jaegerTag.vBool)
        XCTAssertEqual(jaegerTag.vLong, 42)
        XCTAssertNil(jaegerTag.vBinary)
        XCTAssertNil(jaegerTag.vDouble)
        XCTAssertEqual(jaegerTag.vType, .long)
    }
    
    func testJaegerTagConversionBinary() {
        let tag = Tag(key: "testKey", tagType: .binary([UInt8(1)]))
        let jaegerTag = JaegerTag(tag: tag)
        XCTAssertEqual(jaegerTag.key, "testKey")
        XCTAssertNil(jaegerTag.vStr)
        XCTAssertNil(jaegerTag.vBool)
        XCTAssertNil(jaegerTag.vLong)
        XCTAssertEqual(jaegerTag.vBinary, [UInt8(1)])
        XCTAssertNil(jaegerTag.vDouble)
        XCTAssertEqual(jaegerTag.vType, .binary)
    }
    
    func testJaegerTagConversionDouble() {
        let tag = Tag(key: "testKey", tagType: .double(42))
        let jaegerTag = JaegerTag(tag: tag)
        XCTAssertEqual(jaegerTag.key, "testKey")
        XCTAssertNil(jaegerTag.vStr)
        XCTAssertNil(jaegerTag.vBool)
        XCTAssertNil(jaegerTag.vLong)
        XCTAssertNil(jaegerTag.vBinary)
        XCTAssertEqual(jaegerTag.vDouble, 42)
        XCTAssertEqual(jaegerTag.vType, .double)
    }

    func testJaegerLogConversion() {
        let date = Date()
        let tag1 = Tag(key: "testKey1", tagType: .string("testType"))
        let tag2 = Tag(key: "testKey2", tagType: .double(42))

        let log = Log(timestamp: date, fields: [tag1, tag2])
        
        let jaegerLog = JaegerLog(log: log)
        
        XCTAssertEqual(jaegerLog.fields.first?.key, "testKey1")
        XCTAssertEqual(jaegerLog.fields.first?.vStr, "testType")
        XCTAssertEqual(jaegerLog.fields.last?.key, "testKey2")
        XCTAssertEqual(jaegerLog.fields.last?.vDouble, 42)
        XCTAssertEqual(jaegerLog.timestamp, Int64(date.timeIntervalSince1970.microseconds))
    }
    
    func testJaegerSpanReferenceChildOfConversion() {
        let uuid = UUID()
        let context =  Span.Context(traceId: uuid, spanId: uuid)
        let ref = Span.Reference(refType: .childOf, context: context)
        let jaegerRef = JaegerSpan.JaegerSpanReference(ref: ref)
        
        XCTAssertEqual(jaegerRef.spanId, Int64(bitPattern: uuid.firstHalfBits))
        XCTAssertEqual(jaegerRef.traceIdLow, Int64(bitPattern: uuid.firstHalfBits))
        XCTAssertEqual(jaegerRef.traceIdHigh, Int64(bitPattern: uuid.secondHalfBits))
        XCTAssertEqual(jaegerRef.refType, .childOf)
    }
    
    func testJaegerSpanReferenceFollowsFromConversion() {
        let uuid = UUID()
        let context =  Span.Context(traceId: uuid, spanId: uuid)
        let ref = Span.Reference(refType: .followsFrom, context: context)
        let jaegerRef = JaegerSpan.JaegerSpanReference(ref: ref)
        
        XCTAssertEqual(jaegerRef.spanId, Int64(bitPattern: uuid.firstHalfBits))
        XCTAssertEqual(jaegerRef.traceIdLow, Int64(bitPattern: uuid.firstHalfBits))
        XCTAssertEqual(jaegerRef.traceIdHigh, Int64(bitPattern: uuid.secondHalfBits))
        XCTAssertEqual(jaegerRef.refType, .followsFrom)
    }
    
    func testJaegerSpanConversion() {
        let tracer = EmptyTestTracer()
        let startTime = Date()
        let endTime = Date().addingTimeInterval(1)
        let tag = Tag(key: "testKey", tagType: .string("testType"))
        let log = Log(timestamp: startTime, fields: [tag])
        let uuid = UUID()
        let name = "oppName"
        let context =  Span.Context(traceId: uuid, spanId: uuid)
        let ref = Span.Reference(refType: .childOf, context: context)

        var span = Span(tracer: tracer,
                        spanRef: context,
                        parentSpanId: uuid,
                        operationName: name,
                        references: [ref],
                        flag: .debug,
                        startTime: startTime,
                        tags: [tag.key: tag],
                        logs: [log])
        span.finish(at: endTime)
        
        let jaegerSpan = JaegerSpan(span: span)
        
        XCTAssertEqual(jaegerSpan.spanId, Int64(bitPattern: uuid.firstHalfBits))
        XCTAssertEqual(jaegerSpan.traceIdLow, Int64(bitPattern: uuid.firstHalfBits))
        XCTAssertEqual(jaegerSpan.traceIdHigh, Int64(bitPattern: uuid.secondHalfBits))
        XCTAssertEqual(jaegerSpan.operationName, name)
        XCTAssertEqual(jaegerSpan.flags, 2)
        XCTAssertEqual(jaegerSpan.startTime, Int64(startTime.timeIntervalSince1970.microseconds))
        XCTAssertEqual(jaegerSpan.incomplete, false)
        XCTAssertEqual(jaegerSpan.tags?.first?.key, "testKey")
        XCTAssertEqual(jaegerSpan.tags?.first?.vStr, "testType")
        XCTAssertEqual(jaegerSpan.logs?.first?.timestamp, Int64(startTime.timeIntervalSince1970.microseconds))
        XCTAssertEqual(jaegerSpan.logs?.first?.fields.first?.key, "testKey")
        XCTAssertEqual(jaegerSpan.logs?.first?.fields.first?.vStr, "testType")
        XCTAssertEqual(jaegerSpan.duration, Int64(endTime.timeIntervalSince(startTime).microseconds))
    }
}
