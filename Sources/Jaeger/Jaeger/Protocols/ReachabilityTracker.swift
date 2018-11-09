//
//  ReachabilityTracker.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 11/6/18.
//

import Foundation

/**
 A reachability tracker is responsible for gathering the necessary data to evaluate the network connection a device at any point in time.
 */
protocol ReachabilityTracker {

    /**
     Ask for the network reachabilty state of the device without revealing the underlying type of connection.
     
     - Returns: A boolean indication the network reachabilty state of the device.
     */
    func isNetworkReachable() -> Bool

    /**
     Ask for the network reachabilty state with the underlying type of connection.
     
     - Returns: The connection type.
     */
    func getSatus() -> ReachabilityStatus
}

/**
 A list of all possible network connection state.
 
 ````
 case wifi
 case mobileData
 case notConnected
 ````
 */
enum ReachabilityStatus {
    /// The device is using WiFi.
    case wifi
    /// The device is using mobile data.
    case mobileData
    /// The device does not have an internet connection.
    case notConnected
}
