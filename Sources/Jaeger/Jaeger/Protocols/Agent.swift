//
//  Agent.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/31/18.
//

import Foundation

/**
 An Agent is responsible for collecting spans from a tracer and using a SpanSender to report those spans to a collector. An agent needs to do two things:
 
 - Accept spans from the tracer and store these spans if needed.
 - Call the SpanSender's send function as applicable.
 
 When initializing an Agent, we need to specify a SpanSender which it will use to report the collected spans.
 */
public protocol Agent: class {
    /**
     An Agent needs a SpanSender reference that implements the necessary networking functionality to report spans.
     */
    var spanSender: SpanSender { get }

    /**
     Implement necessary logic to record the span data here. Recording includes any caching logic necessary to temporarily hold on to spans and also calling SpanSender's send function to report the spans to the collector.
     
     - Parameter span: A Span sent by the tracer.
     */
    func record(span: Span)
}
