//
//  Reachability.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 11/6/18.
//

import SystemConfiguration

/**
 A reachability tracker using the `SCNetworkReachability` class.
 */
final class Reachability {

    /// Shared network reachability instance.
    private let defaultNetworkReachability: SCNetworkReachability? = getNetworkReachability()

    /**
     Creates a new `SCNetworkReachability` instance with a default host.
     
     - Returns: A new `SCNetworkReachability`.
     */
    private static func getNetworkReachability() -> SCNetworkReachability? {
        // Initializes the socket IPv4 address struct
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)

        let reachability = withUnsafePointer(to: &address) { pointer in
            return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                return SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }
        return reachability
    }

    /**
     Returns the network reachabilty state for a set of flags.
     
     - Parameter flags: The reachability flags.
     - Returns: The network reachabilty state.
     */
    private func isNodeReachable(for flags: SCNetworkReachabilityFlags) -> Bool {

        guard flags.contains(.reachable) else { //Not reachable.
            return false
        }

        guard flags.contains(.connectionRequired) else { //Already connected to internet.
            return true
        }

        guard flags.contains(.interventionRequired) else {
            return (flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic))
        }

        return false
    }
}

extension Reachability: ReachabilityTracker {

    /**
     Ask for the network reachabilty state with the underlying type of connection.
     
     - Returns: The connection type.
     */
    func getStatus() -> ReachabilityStatus {

        guard let currentReachability = defaultNetworkReachability else {
            return .notConnected
        }

        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(currentReachability, &flags)

        guard isNodeReachable(for: flags) else {
            return .notConnected
        }

        guard flags.contains(.isWWAN) else {
            return .wifi
        }

        return .mobileData
    }

    /**
     Ask for the network reachabilty state of the device without revealing the underlying type of connection.
     
     - Returns: A boolean indication the network reachabilty state of the device.
     */
    func isNetworkReachable() -> Bool {
        switch getStatus() {
        case .mobileData, .wifi: return true
        case .notConnected: return false
        }
    }
}
