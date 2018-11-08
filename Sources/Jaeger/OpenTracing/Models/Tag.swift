//
//  Tag.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/29/18.
//

import Foundation

/**
 An abstract representation of a **key:value** pair where the key is restricted to
 a `String` and the value is restricted to a list of acceptable types.
 
 If a collection of tags is intended to be modified over time, than it should not be stored in an array `[Tag]`.
 Tags are usually used to help build an abstraction for a dictionary  with `String` as keys and a list of acceptable types as values.
 When this is the case, a collection of tags should be stored in a dictionary `[Tag.Key: Tag]` as fallows to allow changes efficiently  *O(1)*. Be careful to maintain the integrity of the dictionary!
 
 ### Usage Example: ###
 ````
 let tags: [Tag.Key: Tag] = [:]
 
 func change(tag: Tag) {
 self.tags[tag.key] = tag
 }
 
 ````
 */
public struct Tag: Equatable {
    /// The allowed key type for a tag.
    public typealias Key = String

    /**
     A list of all acceptable Swift fundamental types to represent the value of a tag.
     
     ````
     case string(String)
     case double(Double)
     case bool(Bool)
     case int64(Int64)
     case binary(Binary)
     ````
     */
    public enum TagType: Equatable {
        ///  A swift String
        case string(String)
        ///  A swift Double
        case double(Double)
        ///  A swift Bool
        case bool(Bool)
        /// A swift signed integer
        case int64(Int64)
        /// An array of bytes
        case binary(Binary)
    }

    /**
     Creates a new tag from a  **key:value** pair.
     
     - Parameter key: The `String` key.
     - Parameter tagType: The value (restricted to the allowed types).
     */
    public init(key: Tag.Key, tagType: Tag.TagType) {
        self.key = key
        self.tagType  = tagType
    }

    /// The key of the **key:value** pair.
    public let key: Tag.Key
    /// The value of the **key:value** pair.
    public let tagType: Tag.TagType
}
