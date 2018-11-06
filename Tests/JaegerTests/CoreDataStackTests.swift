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
        let modelURL = Bundle(for: CoreDataAgentTests.self).bundleURL.appendingPathComponent("OTCoreDataAgent.mom")
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
                XCTFail()
                return
        }
        
        let stack = CoreDataStack(modelName: "OTCoreDataAgent", model: model, type: .inMemory)
        XCTAssertEqual(stack.storeType, .inMemory)
        let typeForStore = stack.storeContainer.persistentStoreDescriptions.first?.type
        XCTAssertEqual(typeForStore, NSInMemoryStoreType)
    }
}
