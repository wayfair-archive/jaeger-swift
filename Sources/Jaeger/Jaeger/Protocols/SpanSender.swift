//
//  SpanSender.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/31/18.
//

import Foundation

/**
 The Span sender's responsibility is to report spans to a Span collector. Use this protocol to write any networking code to send your spans to your collector. When initializing an Agent, a SpanSender needs to be supplied to it.
 */
public protocol SpanSender: class {
    /**
     Implement necessary networking logic to send spans to the Span collector. This function will need to be called by the Agent to report spans to the collector.
     
     - Parameter spans: An array of recorded Spans.
     */
    func send<RawSpan: SpanConvertible>(spans: [RawSpan])
}
