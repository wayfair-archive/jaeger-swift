//
//  SpanConvertible.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/31/18.
//

import Foundation

/**
 Use this protocol if you need to create a customized representation of a Span which your collector can injest.
 */
public protocol SpanConvertible: Codable {
    
    /**
     To be used to convert a Span to a SpanConvertible compliant representation of the Span.
     
     - Parameter span: A Span object that needs to be represented as a SpanConvertible.
     - Returns: A `Reference` to a SpanConvertible compliant object.
     */
    static func convert(span: Span) -> Self
    
    /**
     To be used to convert a Span to a SpanConvertible compliant representation of the Span.
     
     - Parameter span: A Span object that needs to be represented as a SpanConvertible.
     */
    init(span: Span)
}
