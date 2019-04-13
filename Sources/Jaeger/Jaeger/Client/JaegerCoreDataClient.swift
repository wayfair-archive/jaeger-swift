//
//  JaegerCoreDataClient.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 11/9/18.
//

#if canImport(CoreData)
import Foundation

/// A Jaeger client using core data as a caching mechanism and a configurable `SpanSender`.
public final class JaegerCoreDataClient {

    /// The tracer used to create all spans.
    public let tracer: JaegerTracer
    /// The underlying agent used by tracer.
    public let agent: JaegerAgent
    /// The underlying sender used by the agent.
    public let sender: SpanSender

    /**
     Creates a new client by specifying the rules for the core data caching mechanism.
     This agent will use a standard `JSONSender`. If a more specific configuration is needed, instantiate a `JSONSender` from one
     of the multiple constructors available.
     
     - Parameter config: The configuration used by the `CoreDataAgent`.
     - Parameter endPointUrl: An API endpoint accepting `JSON` formatted spans`.
     - Parameter session: The underlying `URLSession` to which requests will be forwarded.

     */
    public convenience init(config: CoreDataAgentConfiguration, endPointUrl: URL, session: URLSession = .shared) {
        let sender = JSONSender(endPoint: endPointUrl, session: session)
        self.init(config: config, sender: sender)

    }

    /**
     Creates a new client by specifying the rules for the core data caching mechanism.
     This agent will use a standard `JaegerJSONSender`. If a more specific configuration is needed, instantiate a `JaegerJSONSender` from one
     of the multiple constructors available.
     
     - Parameter config: The configuration used by the `CoreDataAgent`.
     - Parameter process: Description of the service that emits spans.
     - Parameter endPointUrl: An API endpoint accepting `JSON` formatted spans`.
     - Parameter session: The underlying `URLSession` to which requests will be forwarded.
     
     */
    public convenience init(
        config: CoreDataAgentConfiguration,
        process: JaegerBatchProcess,
        endPointUrl: URL,
        session: URLSession = .shared
        ) {
        let sender = JaegerJSONSender(endPoint: endPointUrl, process: process, session: session)
        self.init(config: config, sender: sender)
    }

    /**
     Creates a new client by specifying the rules for the core data caching mechanism.
     
     - Parameter config: The configuration used by the `CoreDataAgent`.
     - Parameter sender: The underlying sender used by the agent.
     */
    public init(config: CoreDataAgentConfiguration, sender: SpanSender) {
        self.sender = sender
        self.agent = JaegerAgent(config: config, sender: sender)
        self.tracer = JaegerTracer(agent: agent)
    }
}
#endif
