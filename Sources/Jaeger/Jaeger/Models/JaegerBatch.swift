//
//  JaegerBatch.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 12/19/18.
//

import Foundation

/// A collection of spans reported out of a process.
struct JaegerBatch: Codable {

    /**
     Creates a new `JaegerBatch`.
     
     - Parameter process: The service that emits spans.
     - Parameter spans: The list of emitted spans.
     */
    init(process: JaegerProcess, spans: [JaegerSpan]) {
        self.process = process
        self.spans = spans
    }

    /// The service that emits spans.
    let process: JaegerProcess
    /// The list of emitted spans.
    let spans: [JaegerSpan]
}

/// Description of the service that emits spans.
struct JaegerProcess: Codable {

    /**
     Creates a new `JaegerProcess`. It is a `Thrift` representation of a `JaegerBatchProcess`.
     
     - Parameter process: The service that emits spans.
     */
    init(process: JaegerBatchProcess) {
        self.serviceName = process.serviceName
        self.tags = process.tags.map(JaegerTag.init)
    }

    /// The name of the service that emits spans.
    let serviceName: String
    /// Additional information for the process.
    let tags: [JaegerTag]?
}

/// Description of the service that emits spans.
public struct JaegerBatchProcess {

    /**
     Creates a new `JaegerBatchProcess`.
     
     - Parameter serviceName: The name of the service that emits spans.
     - Parameter tags: Additional information for the process.
     */
    public init(serviceName: String, tags: [Tag]) {
        self.serviceName = serviceName
        self.tags = tags
    }

    /// The name of the service that emits spans.
    public let serviceName: String
    /// Additional information for the process.
    public let tags: [Tag]
}
