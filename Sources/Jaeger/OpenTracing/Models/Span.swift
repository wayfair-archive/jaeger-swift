//
//  Span.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/29/18.
//

import Foundation

/**
 A **span** represents a task that is being accomplished or was accomplished in a distributed system.
 More abstractly, a span is a node of a **Trace** which is itself a directed acyclic graph representing spans and their relationships.
 This structure encapsulates all the information needed to understand a span as a node: relationships to its parents and children.
 It also saves the information about the task associated to the span.
 
 - For more detail see the [OpenTracing Semantic Specification](https://opentracing.io/specification/).
 */
public struct Span {

    /**
     The minimal information needed to reference a span in a trace.
     The context represents the node (span) in a **Trace** without the relationships to other nodes.
     */
    public struct Context {

        /**
         Creates a new Context from the trace and span ids.
         
         - Parameter traceId: The date at which the event occurred.
         - Parameter spanId: The information associated with the event.
         */
        public init(traceId: UUID, spanId: UUID) {
            self.traceId = traceId
            self.spanId = spanId
        }

        /// The unique number that identifies the (unique) trace in which the node (span) is part of.
        public let traceId: UUID
        /// A unique number to identify a span.
        public let spanId: UUID
    }

    /**
     A reference to a span in a Trace with a relationship context called a `ReferenceType`.
     Abstractly it is an edge of the graph (Trace) when used to reference a node (span) from another node (span).
     */
    public struct Reference {

        /**
         Creates a new Reference from a parent span.
         
         - Parameter of: The parent span.
         - Returns: A `Reference` to the parent.
         */
        public static func child(of parent: Span.Context) -> Reference {
            return Reference(refType: .childOf, context: parent)
        }

        /**
         Creates a new Reference from a parent span with no dependency to its child span.
         
         - Parameter from: The parent span.
         - Returns: A `Reference` to the parent.
         */
        public static func follows(from precedingContext: Span.Context) -> Reference {
            return Reference(refType: .followsFrom, context: precedingContext)
        }

        /**
         A list of possible relationship between spans.
         
         ````
         case childOf
         case followsFrom
         ````
         */
        public enum ReferenceType: String {
            /// A span that depends on a child Span in some capacity.
            case childOf
            /// A span that does not depend in any way on the result of a child.
            case followsFrom
        }

        /// The relationship to the span.
        public let refType: Reference.ReferenceType
        /// The span reference.
        public let context: Span.Context
    }

    /**
     A flag to identify whether a flag is in a debug state.
     
     ````
     case sampled
     case debug
     ````
     
     A debug span can be created for testing scenarios, such as performance analysis.
     As an example, this flag could be used to discard spans in certain parts of a system for testing scenarios.
     */
    public enum Flag {
        /// A *real* span created by a tracer for none debug purpose.
        case sampled
        /// A debug span
        case debug
    }

    /**
     Creates a new `Span`.
     
     - Parameter tracer: The `Tracer` that created this span.
     - Parameter spanRef: The unique identification of the span and its trace.
     - Parameter parentSpan: The parent span.
     - Parameter operationName:  A human-readable string which concisely represents the work done by the span.
     - Parameter flag: This flag specifies if the span is a debug span.
     - Parameter startTime: The time at which the task started.
     - Parameter tags: The tags set before the completion the span.
     - Parameter logs: The logged events that occurrence before the completion the span.
     */

    init(
        tracer: Tracer,
        spanRef: Span.Context,
        parentSpan: Span.Reference?,
        operationName: String,
        flag: Flag,
        startTime: Date,
        tags: [Tag.Key: Tag],
        logs: [Log]
        ) {

        self.tracer = tracer
        self.spanRef = spanRef
        self.parentSpanId = parentSpan?.context.spanId
        self.references = [parentSpan].compactMap { $0 }
        self.operationName = operationName
        self.flag = flag
        self.startTime = startTime
        self.tags = tags
        self.logs = logs
    }

    /// The `Tracer` that created this span.
    private let tracer: Tracer
    /// The unique identification of the span and its trace.
    public let spanRef: Span.Context
    /// The parent span id. Nil for a root node.
    public let parentSpanId: UUID?
    /** A human-readable string which concisely represents the work done by the span.
     See [OpenTracing Semantic Specification](https://opentracing.io/specification/) for the naming conventions.*/
    public let operationName: String
    /// The list of references to other nodes.
    public private(set) var references: [Span.Reference]
    /// This flag specifies if the span is a debug span.
    public let flag: Flag
    ///  The time at which the task started.
    public let startTime: Date
    ///  The time at which the task ended.
    public private(set) var endTime: Date?
    /**  The tags set before the completion the span.
     
     As specified in the OpenTracing documentation, the `tags` property can only be modified before the span ends.
     */
    public private(set) var tags: [Tag.Key: Tag]
    /**  The logged events that occurrence before the completion the span.
     
     - As specified in the OpenTracing documentation, the `logs` property can only be modified before the span ends.
     - As mentioned in the `Tag` documentation, a dictionary is used instead of an array for performance reasons.
     */
    public private(set) var logs: [Log]

    /// A boolean indicating if the task is completed.
    public var isCompleted: Bool {
        return endTime != nil
    }

    /**
     Add or modify an exciting tag.
     
     - Parameter tag: A new or existing tag.
     
     As specified in the OpenTracing documentation, the tags can only be modified before the span ends.
     */
    public mutating func set(tag: Tag) {
        guard !isCompleted else {return}
        tags[tag.key] = tag
    }

    /**
     Add a new log.
     
     - Parameter log: A new log.
     
     As specified in the OpenTracing documentation, the logs can only be modified before the span ends.
     */
    public mutating func log(_ log: Log) {
        guard !isCompleted else {return}
        logs.append(log)
    }

    /**
     An action to indicate that the task was completed.
     
     - Parameter at: The time at which the task was completed. The default value is the current date.
     
     As specified in the OpenTracing documentation, this action will prevent the span to be modified by further actions.
     */
    public mutating func finish(at time: Date = Date()) {
        guard !isCompleted else {return}
        endTime = time
        tracer.report(span: self)
    }
}

// Implementation of 'Equatable' cannot be automatically synthesized in an extension in a different file to the type
extension Span.Context: Hashable {} // Autogenereted on all properties.

extension Span.Reference: Hashable {} // Autogenereted on all properties.

extension Span: Hashable {
    /**
     Only the span context is used to verify equality.
     */
    public static func == (lhs: Span, rhs: Span) -> Bool {
        return lhs.spanRef == rhs.spanRef
    }

    /**
     Only the span context is combined into the hasher.
     
     - Parameter hasher: The hasher to use when combining the components of this instance.
     */
    public func hash(into hasher: inout Hasher) {
        spanRef.hash(into: &hasher)
    }
}
