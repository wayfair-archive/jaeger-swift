//
//  JaegerExtensionsTests.swift
//  JaegerTests
//
//  Created by Simon-Pierre Roy on 10/30/18.
//

import XCTest
@testable import Jaeger

class JaegerExtensionsTests: XCTestCase {

    func testMicrosecondsConversion() {
        let time: TimeInterval = 1
        let microTime = time.microseconds
        XCTAssertEqual(microTime, 1000000)
    }

    func testUUIDFactorizationFirstHalfBits() {
        let uuidBytes: uuid_t = (1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        let uuid = UUID(uuid: uuidBytes)
        
        let powers: [Double] = [0, 8, 24, 32, 40, 48] // Create a Double without overflow.
        let numberAssociatedToBytes: Double = powers.reduce(0) { (result, power) -> Double in
            return result + pow(2,power)
        }
        
        XCTAssertEqual(uuid.firstHalfBits, UInt64(numberAssociatedToBytes))
    }
    
    func testUUIDFactorizationSecondHalfBits() {
        let uuidBytes: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0)
        let uuid = UUID(uuid: uuidBytes)
        
        let powers: [Double] = [0, 8, 24, 32, 40, 48] // Create a Double without overflow.
        let numberAssociatedToBytes: Double = powers.reduce(0) { (result, power) -> Double in
            return result + pow(2,power)
        }
        
        XCTAssertEqual(uuid.secondHalfBits, UInt64(numberAssociatedToBytes))
    }
}
