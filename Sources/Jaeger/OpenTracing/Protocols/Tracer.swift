//
//  Tracer.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/29/18.
//

import Foundation

/**
 An interface representing chosen functionalities of the OpenTracing Tracer specifications. Any class implementing this interface should be able to create and relay spans.
 
 Usually a Tracer should be able to transfer spans across process boundaries. In this implementation, the tracer will only be able to create spans and relay them to another system responsible for communication.
 
 - Warning:
    Since a `Span` will strongly retain the tracer, do not keep a strong reference to any span to avoid memory leaks.
 */
public protocol Tracer: class {
    /**
     A point of entry to start a new span wrapped in an OTSpan.
     
     - Parameter operationName: A human-readable string which concisely represents the work done by the Span. See [OpenTracing Semantic Specification](https://opentracing.io/specification/) for the naming conventions.
     - Parameter reference: The relationship to a node (span).
     - Parameter startTime: The time at which the task was started.
     - Parameter tags: Tags to be included at the creation of the span.
     
     - Returns: A new `Span` wrapped in an OTSpan.
     */
    func startSpan(operationName: String, referencing reference: Span.Reference?, startTime: Date, tags: [Tag]) -> OTSpan
    /**
     Transfer a **completed** span to the tracer.
     
     - Parameter span: A **completed** span.
     
     The span should be completed before being reported to the tracer. Common implementation of a Tracer should reject incomplete span.
     */
    func report(span: Span)
}

extension Tracer {
    /**
     A point of entry to start a new span wrapped in an OTSpan.
     
     - Parameter operationName: A human-readable string which concisely represents the work done by the Span. See [OpenTracing Semantic Specification](https://opentracing.io/specification/) for the naming conventions.
     - Parameter childOf: The parent node (span) .
     - Parameter startTime: The time at which the task was started.
     - Parameter tags: Tags to be included at the creation of the span.
     
     - Returns: A new `Span` (wrapped in an OTSpan) with a `childOf` relationship.
     */
    public func startSpan(operationName: String, childOf parent: Span.Context, startTime: Date = Date(), tags: [Tag] = []) -> OTSpan {
        let reference = Span.Reference(refType: .childOf, context: parent)
        return startSpan(operationName: operationName, referencing: reference, startTime: startTime, tags: tags)
    }

    /**
     A point of entry to start a new span wrapped in an OTSpan.
     
     - Parameter operationName: A human-readable string which concisely represents the work done by the Span. See [OpenTracing Semantic Specification](https://opentracing.io/specification/) for the naming conventions.
     - Parameter followsFrom: The parent node (span) .
     - Parameter startTime: The time at which the task was started.
     - Parameter tags: Tags to be included at the creation of the span.
     
     - Returns: A new `Span` (wrapped in an OTSpan) with a `followsFrom` relationship.
     */
    public func startSpan(operationName: String, followsFrom parent: Span.Context, startTime: Date = Date(), tags: [Tag] = []) -> OTSpan {
        let reference = Span.Reference(refType: .followsFrom, context: parent)
        return startSpan(operationName: operationName, referencing: reference, startTime: startTime, tags: tags)
    }

    /**
     A point of entry to start a new span wrapped in an OTSpan.
     
     - Parameter operationName: A human-readable string which concisely represents the work done by the Span. See [OpenTracing Semantic Specification](https://opentracing.io/specification/) for the naming conventions.
     - Parameter startTime: The time at which the task was started.
     - Parameter tags: Tags to be included at the creation of the span.
     
     - Returns: A new `Span` (wrapped in an OTSpan) with no relationship. This is a root node.
     */
    public func startRootSpan(operationName: String, startTime: Date = Date(), tags: [Tag] = []) -> OTSpan {
        return startSpan(operationName: operationName, referencing: nil, startTime: startTime, tags: tags)
    }
}

extension Tracer {

    /**
     A point of entry to a start a new span wrapped in an OTSpan.
     
     - Parameter operationName: An operation name which concisely represents the work done by the Span. See [OpenTracing Semantic Specification](https://opentracing.io/specification/) for the naming conventions.
     - Parameter references: The relationship to a node (span).
     - Parameter startTime: The time at which the task was started.
     - Parameter tags: Tags to be included at the creation of the span.
     
     - Returns: A new `Span` wrapped in an OTSpan.
     */
    public func startSpan<Operation: RawRepresentable>(operationName: Operation, references: Span.Reference?, startTime: Date, tags: [Tag]) -> OTSpan where Operation.RawValue == String {
        return startSpan(operationName: operationName.rawValue, referencing: references, startTime: startTime, tags: tags)
    }

    /**
     A point of entry to start a new span wrapped in an OTSpan.
     
     - Parameter operationName: An operation name which concisely represents the work done by the Span. See [OpenTracing Semantic Specification](https://opentracing.io/specification/) for the naming conventions.
     - Parameter childOf: The parent node (span) .
     - Parameter startTime: The time at which the task was started.
     - Parameter tags: Tags to be included at the creation of the span.
     
     - Returns: A new `Span` (wrapped in an OTSpan) with a `childOf` relationship.
     */
    public func startSpan<Operation: RawRepresentable>(operationName: Operation, childOf parent: Span.Context, startTime: Date = Date(), tags: [Tag] = []) -> OTSpan where Operation.RawValue == String {
        return startSpan(operationName: operationName.rawValue, childOf: parent, startTime: startTime, tags: tags)
    }

    /**
     A point of entry to start a new span wrapped in an OTSpan.
     
     - Parameter operationName: An operation name which concisely represents the work done by the Span. See [OpenTracing Semantic Specification](https://opentracing.io/specification/) for the naming conventions.
     - Parameter followsFrom: The parent node (span) .
     - Parameter startTime: The time at which the task was started.
     - Parameter tags: Tags to be included at the creation of the span.
     
     - Returns: A new `Span` (wrapped in an OTSpan) with a `followsFrom` relationship.
     */
    public func startSpan<Operation: RawRepresentable>(operationName: Operation, followsFrom parent: Span.Context, startTime: Date = Date(), tags: [Tag] = []) -> OTSpan where Operation.RawValue == String {
        return startSpan(operationName: operationName.rawValue, followsFrom: parent, startTime: startTime, tags: tags)
    }

    /**
     A point of entry to start a new span wrapped in an OTSpan.
     
     - Parameter operationName: An operation name which concisely represents the work done by the Span. See [OpenTracing Semantic Specification](https://opentracing.io/specification/) for the naming conventions.
     - Parameter startTime: The time at which the task was started.
     - Parameter tags: Tags to be included at the creation of the span.
     
     - Returns: A new `Span` (wrapped in an OTSpan) with no relationship. This is a root node.
     */
    public func startRootSpan<Operation: RawRepresentable>(operationName: Operation, startTime: Date = Date(), tags: [Tag] = []) -> OTSpan where Operation.RawValue == String {
        return startRootSpan(operationName: operationName.rawValue, startTime: startTime, tags: tags)
    }
}
