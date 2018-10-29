//
//  UUID+Extensions.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 10/29/18.
//

import Foundation

extension UUID {
    
    /**
     A integer representation of the first 64 bits of the UUID.
     
     This still produces a random number, since all bits were randomly generated with no correlation.
     See the [UUID documentation](https://developer.apple.com/documentation/foundation/nsuuid).
     */
    var firstHalfBits: UInt64 {
        let bytes = self.uuid
        
        let firstHalfBits: UInt64 =  UInt64(bytes.0) |
            UInt64(bytes.1) << 8 |
            UInt64(bytes.2) << 16 |
            UInt64(bytes.3) << 24 |
            UInt64(bytes.4) << 32 |
            UInt64(bytes.5) << 40 |
            UInt64(bytes.6) << 48 |
            UInt64(bytes.7) << 56
        
        return firstHalfBits
    }
    
    /**
     A integer representation of the last 64 bits of the UUID.
     
     This still produces a random number, since all bits were randomly generated with no correlation.
     See the [UUID documentation](https://developer.apple.com/documentation/foundation/nsuuid).
     */
    var secondHalfBits: UInt64 {
        let bytes = self.uuid
        
        let secondHalfBits: UInt64 =  UInt64(bytes.8) |
            UInt64(bytes.9) << 8 |
            UInt64(bytes.10) << 16 |
            UInt64(bytes.11) << 24 |
            UInt64(bytes.12) << 32 |
            UInt64(bytes.13) << 40 |
            UInt64(bytes.14) << 48 |
            UInt64(bytes.15) << 56
        
        return secondHalfBits
    }
}
