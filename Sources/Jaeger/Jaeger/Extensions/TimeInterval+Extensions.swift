//
//  TimeInterval+Extensions.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/29/18.
//

import Foundation

/// A type to express time intervals in microseconds.
typealias Microseconds = Double

extension TimeInterval {
    /// A time interval expressed in microseconds.
    var microseconds: Microseconds {
        return self * 1e6
    }
}
