//
//  JSONSender.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 11/7/18.
//

import Foundation

/// A `SpanSender` designed to send spans at a specified `URL` using the `JSON` format.
public final class JSONSender: SpanSender {

    /**
     A list of all acceptable `HTTP` methods used by the underlying `URLRequest`.
     
     ````
     case post
     case put
     case get
     ````
     */
    public enum HttpMethod: String {
        ///  The `POST` method.
        case post = "POST"
        ///  The `PUT` method.
        case put = "PUT"
        ///  The `GET` method.
        case get = "GET"
    }

    /**
     A list of global constants for the `JSONSender`.
     */
    private enum Constants {
        /// The fixed `JSON` encoder.
        static let jsonEncoder = JSONEncoder()
        /// The `HTTP` header field for the content type.
        static let contentHeaderName = "Content-Type"
        /// The string representing the `JSON` content type.
        static let contentType = "application/json"
    }

    /**
     Creates a new `JSONSender` by specifying the endpoint.
     
     - Parameter endPoint: An API endpoint accepting `JSON` formatted spans.
     - Parameter session: The underlying `URLSession` to which requests will be forwarded.
     - Parameter httpMethod: The `HTTP` method used to send out spans at the specified endpoint.
     - Parameter requestHeaders: A list of `[HTTPHeaderField: Value]` for the underlying `URLRequest`.
     
     If this basic implementation does not meet your requirements, simply make your own network service (or wrapper) conform to `SpanSender`.
     */
    public init(
        endPoint: URL,
        session: URLSession = .shared,
        httpMethod: HttpMethod = .post,
        requestHeaders: [String: String] = [:]
        ) {

        self.endPoint = endPoint
        self.session = session
        self.httpMethod = httpMethod
        self.requestHeaders = requestHeaders
    }

    /// An API endpoint accepting `JSON` formatted spans.
    private let endPoint: URL
    /// The underlying `URLSession` to which requests will be forwarded.
    private let session: URLSession
    /// The `HTTP` method used to send out spans at the specified endpoint.
    private let httpMethod: HttpMethod
    /// A list of `[HTTPHeaderField: Value]` for the underlying `URLRequest`.
    private let requestHeaders: [String: String]

    /**
     Call this function to send spans to a specific endpoint using `JSON` encoding.
     
     - Parameter spans: An array of recorded Spans.
     */
    public func send<RawSpan: SpanConvertible>(spans: [RawSpan], completion: CompletionStatus?) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            if let strongSelf = self {
                strongSelf.trySendRequest(for: spans, completion: completion)
            } else {
                completion?(nil)
            }
        }
    }

    /**
     It converts spans to `Data` and sends it using a `URLSessionDataTask`.
     
     - Parameter spans: An array of recorded Spans.
     - Parameter completion: A function used to acknowledge the success or the failure after attempting to send the spans.
     */
    private func trySendRequest<RawSpan: SpanConvertible>(for spans: [RawSpan], completion: CompletionStatus?) {
        do {
            let data = try Constants.jsonEncoder.encode(spans)
            sendRequest(for: data, completion: completion)
        } catch {
            completion?(error)
        }
    }

    /**
     Sends spans using a `URLSessionDataTask`.
     
     - Parameter data: converted spans to binary.
     - Parameter completion: A function used to acknowledge the success or the failure after attempting to send the spans.
     */
    private func sendRequest(for data: Data, completion: CompletionStatus?) {
        var request = URLRequest(url: endPoint)

        request.httpMethod = httpMethod.rawValue
        request.httpBody = data
        request.setValue(Constants.contentType, forHTTPHeaderField: Constants.contentHeaderName)

        for (headerField, value) in requestHeaders {
            request.setValue(value, forHTTPHeaderField: headerField)
        }

        let task = session.dataTask(with: request) { (_, _, error) in
            completion?(error)
        }

        task.resume()
    }
}
