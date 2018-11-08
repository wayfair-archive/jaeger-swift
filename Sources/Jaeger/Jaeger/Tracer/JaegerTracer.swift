//
//  JaegerTracer.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 11/7/18.
//

import Foundation

/// A tracer for Jaeger spans using a core data agent for the caching process.
public typealias JaegerTracer = CDTracer<JaegerSpan>

/// A tracer using a core data agent for the caching process.
public final class CDTracer<RawSpan: SpanConvertible>: Tracer {
    
    /// A fixed id for the tracer.
    let tracerId = UUID()
    /// The agent used for the caching process.
    private let agent: CDAgent<RawSpan>
    
    /**
     Creates a new tracer with a unique identifier.
     
     - Parameter agent: The agent used for the caching process.
     */
    init(agent: CDAgent<RawSpan>) {
        self.agent = agent
    }
    
    /**
     A point of entry the crete a start a new span wrapped in an OTSpan.
     
     - Parameter operationName: A human-readable string which concisely represents the work done by the Span. See [OpenTracing Semantic Specification](https://opentracing.io/specification/) for the naming conventions.
     - Parameter reference: The relationship to a node (span).
     - Parameter startTime: The time at which the task was started.
     - Parameter tags: Tags to be included at the creation of the span.
     
     - Returns: A new `Span` wrapped in an OTSpan.
     */
    public func startSpan(operationName: String, reference: Span.Reference?, startTime: Date, tags: [Tag]) -> OTSpan {
        let span = Span(
            tracer: self,
            spanRef: .init(traceId: self.tracerId, spanId: UUID()),
            parentSpanId: reference?.context.spanId,
            operationName: operationName,
            references: [],
            flag: .sampled,
            startTime: startTime,
            tags: [:],
            logs: []
        )
        
        return OTSpan(span: span)
    }
    
    /**
     Transfer a **completed** span to the tracer.
     
     - Parameter span: A **completed** span.
     */
    public func report(span: Span) {
        self.agent.record(span: span)
    }
}
