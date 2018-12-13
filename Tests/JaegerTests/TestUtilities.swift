//
//  TestUtilities.swift
//  JaegerTests
//
//  Created by Simon-Pierre Roy on 10/30/18.
//

import XCTest
@testable import Jaeger
import CoreData

class TestUtilities {

    /**
     Useful and reusable constants to help the construction of new tests.
     */
    enum Constants {
        /// Fixed UUID for a `Span`
        static let spanUUID = UUID(uuidString: "271C452F-D78A-4612-9425-79BCC21B3811")!
        /// Fixed UUID for a `Trace`
        static let traceUUID = UUID(uuidString: "54186C03-8F55-403F-97D0-CF602CE3D903")!
        /// The name of the core data agent model file.
        static let coreDataAgentModelName = "OTCoreDataAgent"
    }

    private init() {} // Only static methods for the class.

    /**
     A span constructor with default parameters for all fields.
     
     Useful to test Spans when the result of the report function is needed.
     
     - Parameter name: Default is \"testSpan\".
     - Parameter parentUUID:Default is `nil`.
     - Parameter startTime: Default is `Date()`.
     - Parameter spanUUID:  Default is `TestUtilitiesConstants.spanUUID`.
     - Parameter traceUUID: Default is `TestUtilitiesConstants.traceUUID`.
     - Parameter tracer: Default is `EmptyTestTracer`.
     - Parameter logs: Default is `[]`.
     - Parameter tags: Default is `[:]`.
     - Parameter references: Default is `[]`.
     
     */
    static func getNewTestSpan(
        name: String = "testSpan",
        startTime: Date = Date(),
        spanUUID: UUID = TestUtilities.Constants.spanUUID,
        traceUUID: UUID = TestUtilities.Constants.traceUUID,
        tracer: Tracer = EmptyTestTracer(),
        logs: [Log] = [],
        tags: [Tag.Key: Tag] = [:],
        references: [Span.Reference] = []
        ) -> Span {

        return Span(
            tracer: tracer,
            spanRef: Span.Context(traceId: traceUUID, spanId: spanUUID),
            parentSpan: nil,
            operationName: name,
            flag: .debug,
            startTime: startTime,
            tags: tags,
            logs: logs
        )
    }

    /** The `OTCoreDataAgent.mom` file is generated during the creation of the Jaeger framework and added to its bundle. A link to the file was added the Jaeger project (drag and drop + setting the location relative to build products and then edit the project file to fix the path). This file was added as a resource for the test bundle in the build phases. Since the framework is added as a dependency of the test target, the file will be created before the compilation of the test project. */
    private static let URLForCoreDataAgentModel = Bundle(for: TestUtilities.self).bundleURL.appendingPathComponent(Constants.coreDataAgentModelName + ".mom")

    /** A shared model for the OTCoreDataAgent file. The model is shared in order to avoid having multiple `NSManagedObjectModel` claiming the class `CoreDataSpan`. This would happen since each test function is associated to a new instance of the `XCTestCase` class! Not using a shared model would result in multiples core data warnings. */
    static let modelForCoreDataAgent: NSManagedObjectModel = {
        guard let model = NSManagedObjectModel(contentsOf: URLForCoreDataAgentModel) else {
            fatalError()
        }
        return model
    }()
}
