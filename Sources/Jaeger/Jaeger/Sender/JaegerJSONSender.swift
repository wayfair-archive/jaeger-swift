//
//  JaegerJSONSender.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 12/19/18.
//

import Foundation
/// A `SpanSender` designed to send spans at a specified `URL` using the `JSON` format. This sender works exactly as a `JSONSender`, it only modifies the payload sent to the endpoint. The spans will be wrapped in a `Batch` according to the [Jaeger.Thrift](https://github.com/jaegertracing/jaeger-idl/blob/master/thrift/jaeger.thrift) definition.

public final class JaegerJSONSender: JSONSender {

    /**
     Creates a new `JaegerJSONSender` by specifying the endpoint. This sender works exactly as a `JSONSender`, it only modifies the payload sent to the endpoint. The spans will be wrapped in a `Batch` according to the [Jaeger.Thrift](https://github.com/jaegertracing/jaeger-idl/blob/master/thrift/jaeger.thrift) definition.
     
     - Parameter endPoint: An API endpoint accepting `JSON` formatted spans.
     - Parameter process: The proccess information for a `Jeager` Collector.
     - Parameter session: The underlying `URLSession` to which requests will be forwarded.
     - Parameter httpMethod: The `HTTP` method used to send out spans at the specified endpoint.
     - Parameter requestHeaders: A list of `[HTTPHeaderField: Value]` for the underlying `URLRequest`.
     
     If this basic implementation does not meet your requirements, simply make your own network service (or wrapper) conform to `SpanSender`.
     */
    public init(
        endPoint: URL,
        process: JaegerBatchProcess,
        session: URLSession = .shared,
        httpMethod: HttpMethod = .post,
        requestHeaders: [String: String] = [:]
        ) {
        self.process = process
        super.init(endPoint: endPoint, session: session, httpMethod: httpMethod, requestHeaders: requestHeaders)
    }

    /// The process information for a `Jeager` Collector. It will be used to construct a `Batch` following the [Jaeger.Thrift](https://github.com/jaegertracing/jaeger-idl/blob/master/thrift/jaeger.thrift) definition.
    public let process: JaegerBatchProcess

    /**
     It converts spans to `Data` by wrapping them in a `Batch` following the [Jaeger.Thrift](https://github.com/jaegertracing/jaeger-idl/blob/master/thrift/jaeger.thrift) definition. It sends it using a `URLSessionDataTask`.
     
     - Parameter spans: An array of recorded Spans.
     - Parameter completion: A function used to acknowledge the success or the failure after attempting to send the spans.
     */
    override func trySendRequest<RawSpan: SpanConvertible>(for spans: [RawSpan], completion: CompletionStatus?) {

        guard let jaegerSpans = spans as? [JaegerSpan] else {
            super.trySendRequest(for: spans, completion: completion)
            return
        }

        let process = JaegerProcess(process: self.process)
        let batch = JaegerBatch(process: process, spans: jaegerSpans)

        do {
            let data = try Constants.jsonEncoder.encode(batch)
            super.sendRequest(for: data, completion: completion)
        } catch {
            completion?(error)
        }
    }
}
