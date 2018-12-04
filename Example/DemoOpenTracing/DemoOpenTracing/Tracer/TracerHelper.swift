//
//  TracerHelper.swift
//  DemoOpenTracing
//
//  Created by Simon-Pierre Roy on 11/21/18.
//  Copyright © 2018 DemoApp. All rights reserved.
//

import Foundation
import Jaeger

class DemoAgentDelegate: CoreDataAgentErrorDelegate {
    func handleError(_ error: Error) {
        print(error)
    }
}

class ConsoleSpanSender: SpanSender {
    func send<RawSpan>(spans: [RawSpan], completion: CompletionStatus?) where RawSpan: SpanConvertible {
        print(spans)
    }
}

class NoopTracer: WrapTracer {
    func startSpan<Caller>(callerType: Caller.Type, callerFunction: String, childOf: WrapSpan?) -> WrapSpan {
        return .noop
    }
}
