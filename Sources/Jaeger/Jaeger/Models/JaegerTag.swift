//
//  JaegerTag.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/29/18.
//

import Foundation

/**
 The Jaeger version of an OpenTracing Tag. It is a flatten version of a strongly typed **key:value** pair.
 
 See the [Jaeger.Thrift](https://github.com/jaegertracing/jaeger-idl/blob/master/thrift/jaeger.thrift) definition.
 */
struct JaegerTag: Codable {

    /**
     Creates a Jaeger Tag from an OpenTracing Tag.
     
     - Parameter tag: An OpenTracing Tag.
     */
    init(tag: Tag) {
        switch tag.tagType {
        case .string(let string):
            self.init(key: tag.key, string: string)
        case .double(let dobule):
            self.init(key: tag.key, double: dobule)
        case .bool(let bool):
            self.init(key: tag.key, bool: bool)
        case .int64(let int64):
            self.init(key: tag.key, long: int64)
        case .binary(let binary):
            self.init(key: tag.key, binary: binary)
        }
    }

    /**
     Creates a Jaeger Tag from a `String` and a key.
     
     - Parameter key: The string key of the **key:value** pair.
     - Parameter string: A `String` value for the pair.
     
     Unnecessary properties will be set to nil.
     */
    init(key: String, string: String) {
        self.key = key
        vType = .string
        vStr = string
        vDouble = nil
        vBool = nil
        vLong = nil
        vBinary = nil
    }

    /**
     Creates a Jaeger Tag from a `Double` and a key.
     
     - Parameter key: The string key of the **key:value** pair.
     - Parameter double: A `Double` value for the pair.
     
     Unnecessary properties will be set to nil.
     */
    init(key: String, double: Double) {
        self.key = key
        vType = .double
        vStr = nil
        vDouble = double
        vBool = nil
        vLong = nil
        vBinary = nil
    }

    /**
     Creates a Jaeger Tag from a `Bool` and a key.
     
     - Parameter key: The string key of the **key:value** pair.
     - Parameter bool: A `Bool` value for the pair.
     
     Unnecessary properties will be set to nil.
     */
    init(key: String, bool: Bool) {
        self.key = key
        vType = .bool
        vStr = nil
        vDouble = nil
        vBool = bool
        vLong = nil
        vBinary = nil
    }

    /**
     Creates a Jaeger Tag from an `Int64` and a key.
     
     - Parameter key: The string key of the **key:value** pair.
     - Parameter long: An `Int64` value for the pair.
     
     Unnecessary properties will be set to nil.
     */
    init(key: String, long: Int64) {
        self.key = key
        vType = .long
        vStr = nil
        vDouble = nil
        vBool = nil
        vLong = long
        vBinary = nil
    }

    /**
     Creates a Jaeger Tag from a `Binary` and a key.
     
     - Parameter key: The string key of the **key:value** pair.
     - Parameter binary: A `Binary` value for the pair.
     
     Unnecessary properties will be set to nil.
     */
    init(key: String, binary: Binary) {
        self.key = key
        vType = .binary
        vStr = nil
        vDouble = nil
        vBool = nil
        vLong = nil
        vBinary = binary
    }

    /**
     A list of all acceptable Thrift fundamental types to represent the value of a tag.
     
     ````
     case string
     case double
     case bool
     case int64
     case binary
     ````
     */
    enum TagType: String, Codable {
        ///  A Thrift String
        case string = "STRING"
        ///  A Thrift Double
        case double = "DOUBLE"
        ///  A Thrift Bool
        case bool = "BOOL"
        ///  A Thrift Long
        case long = "LONG"
        ///  A Thrift Binary
        case binary = "BINARY"
    }

    /// The string key of the **key:value** pair.
    let key: String
    /// The type associated to the value.
    let vType: JaegerTag.TagType
    /// The `String` value if the vType is `String`, else it will be nil.
    let vStr: String?
    /// The `Double` value if the vType is `Double`, else it will be nil.
    let vDouble: Double?
    /// The `Bool` value if the vType is `Bool`, else it will be nil.
    let vBool: Bool?
    /// The `Int64` value if the vType is `Int64`, else it will be nil.
    let vLong: Int64?
    /// The `Binary` value if the vType is `Binary`, else it will be nil.
    let vBinary: Binary?
}
