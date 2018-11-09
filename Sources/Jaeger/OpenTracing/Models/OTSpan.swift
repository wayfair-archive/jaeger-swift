//
//  OTSpan.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/29/18.
//

import Foundation

/**
 A class wrapper around a `Span`.
 
 This class is a thread safe wrapper around `Span` that allows performance optimization and reference semantics to a span.
 Read and write accesses are synchronized in a concurrent queue with a [Utility Priority](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html).
 Every write access is dispatched as a barrier work item on the queue allowing read operations to finish.
 Every read access is dispatched as a regular work item on the concurrent queue.
 
 */
public final class OTSpan { // final class:  enables direct dispatch

    /// The synchronizing queue for all span operations.
    private let synchronizingQueue: DispatchQueue

    /**
     Creates a new `OTSpan` from a `Span`.
     
     - Parameter span: A new span (not completed).
     
     A common *low* priority synchronizing queue is used.
     */
    convenience init(span: Span) {
        let defaultSynchronizingQueue = DispatchQueue(
            label: "com.wayfair.opentracing.otspan",
            qos: .utility,
            attributes: .concurrent
        )

        self.init(span: span, synchronizingQueue: defaultSynchronizingQueue)
    }

    /**
     Creates a new `OTSpan` synchronized a specify queue. **Only use this init for test purpose.**
     
     - Parameter span: A new span (not completed).
     - Parameter synchronizingQueue: A concurrent queue used for synchronizing all span operations.
     
     **Only use this init for test purpose! The default queue should always be used**.
     */
    init(span: Span, synchronizingQueue: DispatchQueue) {
        self.synchronizingQueue = synchronizingQueue
        self.backingSpan = span
        self.spanRef = span.spanRef
    }

    /// The reference for the current span. Useful to create a child span.
    public let spanRef: Span.Context

    /// The span value synchronized by the concurrent queue.
    private var backingSpan: Span

    /**
     The asynchronous setter of the span.
     
     - Parameter closure: The operations to apply to the span.
     - Parameter span: A reference to the span on which to closure will be applied.
     
     */
    public func set(_ closure: @escaping (_ span: inout Span) -> Void) {
        self.synchronizingQueue.async(flags: .barrier) {
            closure(&self.backingSpan)
        }
    }

    /**
     The asynchronous getter of the span.
     
     - Parameter closure: The asynchronous getter.
     - Parameter span: A copy of the current span.
     
     */
    public func get(_ closure: @escaping (_ span: Span) -> Void) {
        self.synchronizingQueue.async {
            closure(self.backingSpan)
        }
    }

    /**
     An action to indicate that the task was completed.
     This function will forward the request to the span by using the specified date or the current date.
     
     - Parameter at: The time at which the task was completed. The default value is the current date.
     
     This function avoid timing errors by keeping a reference to the current date before asynchronously forwarding the request to the span.
     */
    public final func finish(at time: Date = Date()) { // Added “final” to be explicit, but func is already final from final class.
        self.set { $0.finish(at: time) }
    }
}
