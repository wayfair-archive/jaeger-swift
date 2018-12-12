//
//  DemoTracer.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import Foundation
import Jaeger

protocol WrapTracer: class {
    func startSpan<Caller>(callerType: Caller.Type, callerFunction: String, followsFrom: WrapSpan?) -> WrapSpan
    func startSpan<Caller>(callerType: Caller.Type, callerFunction: String, childOf: WrapSpan?) -> WrapSpan
}

extension WrapTracer {
    func startSpan<Caller>(callerType: Caller.Type, callerFunction: String = #function, followsFrom: WrapSpan? = nil) -> WrapSpan {
        return startSpan(callerType: callerType, callerFunction: callerFunction, followsFrom: followsFrom)
    }

    func startChildSpan<Caller>(callerType: Caller.Type, callerFunction: String = #function, chilfOf: WrapSpan? = nil) -> WrapSpan {
        return startSpan(callerType: callerType, callerFunction: callerFunction, childOf: chilfOf)
    }
}

enum WrapSpan {

    private static let mainThreadTag = Tag(key: "onUIThread", tagType: .bool(true))

    case noop
    case span(OTSpan)

    private var span: OTSpan? {
        switch self {
        case .span(let span): return span
        case .noop: return nil
        }
    }

    func finish() {
        span?.finish()
    }

    func set(tag: Tag) {
        span?.set { $0.set(tag: tag) }
    }

    func addOnMainThreadTag() {
        span?.set { $0.set(tag: WrapSpan.mainThreadTag) }
    }
}

class DemoTracer: WrapTracer {

    private let client: JaegerCoreDataClient

    init(sender: SpanSender, savingInterval: Double, sendingInterval: Double) {

        let config = CoreDataAgentConfiguration(
            averageMaximumSpansPerSecond: 10,
            savingInterval: savingInterval,
            sendingInterval: sendingInterval,
            errorDelegate: DemoAgentDelegate(),
            coreDataFolderURL: nil
        )

        guard let CDconfig = config else { fatalError() }
        self.client = JaegerCoreDataClient(config: CDconfig, sender: sender)
    }

    func startSpan<Caller>(
        callerType: Caller.Type,
        callerFunction: String  = #function,
        followsFrom: WrapSpan? = nil
        ) -> WrapSpan {

        let callerName = String(describing: callerType)
        let spanName: String = callerName + "." + callerFunction
        if let followsFrom = followsFrom, case let .span(span) = followsFrom {
            let newSpan = client.tracer.startSpan(operationName: spanName, followsFrom: span.spanRef)
            return WrapSpan.span(newSpan)
        } else {
            let span = client.tracer.startRootSpan(operationName: spanName)
            return WrapSpan.span(span)
        }
    }

    func startSpan<Caller>(
        callerType: Caller.Type,
        callerFunction: String  = #function,
        childOf: WrapSpan? = nil
        ) -> WrapSpan {

        let callerName = String(describing: callerType)
        let spanName: String = callerName + "." + callerFunction
        if let childOf = childOf, case let .span(span) = childOf {
            let newSpan = client.tracer.startSpan(operationName: spanName, childOf: span.spanRef)
            return WrapSpan.span(newSpan)
        } else {
            let span = client.tracer.startRootSpan(operationName: spanName)
            return WrapSpan.span(span)
        }
    }
}
