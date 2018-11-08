//
//  SpanSender.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/31/18.
//

import Foundation

/// A function used to acknowledge the end of a task with an optional error message in case of failure.
public typealias CompletionStatus = (Error?)-> Void

/**
 The Span sender's responsibility is to report spans to a Span collector. Use this protocol to write any networking code to send your spans to your collector. When initializing an Agent, a SpanSender needs to be supplied to it.
 */
public protocol SpanSender: class {
    /**
     Implement necessary networking logic to send spans to the Span collector. This function will need to be called by the Agent to report spans to the collector.
     
     - Parameter spans: An array of recorded Spans.
     - Parameter completion: A function used to acknowledge the success or the failure after attempting to send the spans.
     */
    func send<RawSpan: SpanConvertible>(spans: [RawSpan], completion: CompletionStatus?)
}
