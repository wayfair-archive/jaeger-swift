//
//  CoreDataStackTests.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 11/6/18.
//

import XCTest
import CoreData
@testable import Jaeger

class CoreDataStackTests: XCTestCase {
    
    func testInitCoreDataStackInMemory() {
        let stack = CoreDataStack(
            modelName: TestUtilities.Constants.coreDataAgentModelName,
            model: TestUtilities.modelForCoreDataAgent,
            type: .inMemory
        )
        
        XCTAssertEqual(stack.storeType, .inMemory)
        let typeForStore = stack.storeContainer.persistentStoreDescriptions.first?.type
        XCTAssertEqual(typeForStore, NSInMemoryStoreType)
    }
}
