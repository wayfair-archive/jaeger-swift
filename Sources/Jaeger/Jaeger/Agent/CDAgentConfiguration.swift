//
//  CDAgentConfiguration.swift
//  JaegerTests
//
//  Created by Simon-Pierre Roy on 11/8/18.
//

import Foundation

/**
 The configuration used by the `CoreDataAgent` agent to set up the core data stack and saving behavior.
 */
public struct CDAgentConfiguration {
    
    /**
     Creates a new configuration.
     
     - Parameter averageMaximumSpansPerSecond: The maximum number of spans per seconds to be saved in memory before the next saving operation on disk.
     - Parameter savingInterval: The time between each saving operation on disk.
     - Parameter sendingInterval: The time between each sending tasks to the collector.
     - Parameter errorDelegate: The error delegate. Any core data error or network error will be forwarded to the delegate.
     - Parameter coreDataFolderURL: An optional URL to a folder where the core data files will be saved. When not specified the `NSPersistentContainer.defaultDirectoryURL()` will be used.
     
     - Warning:
     Every parameter should be strictly positive and the sending interval should be greater than the saving interval.
     */
    public init?(
        averageMaximumSpansPerSecond: Int,
        savingInterval: TimeInterval,
        sendingInterval: TimeInterval,
        errorDelegate: CDAgentErrorDelegate? = nil,
        coreDataFolderURL: URL?
        ) {
        
        guard averageMaximumSpansPerSecond > 0,
            savingInterval > 0,
            sendingInterval > 0,
            savingInterval < sendingInterval else {
                return nil
        }
        
        self.errorDelegate = errorDelegate
        self.coreDataFolderURL = coreDataFolderURL
        self.maximumSpansPerSecond = averageMaximumSpansPerSecond
        self.savingInterval = savingInterval
        self.sendingInterval = sendingInterval
        let maxPerSaving = (Double(averageMaximumSpansPerSecond) * savingInterval).rounded(.up)
        let maxPerSending = (Double(averageMaximumSpansPerSecond) * sendingInterval).rounded(.up)
        self.maximunSpansPerSavingInterval =  Int(maxPerSaving)
        self.maximunSpansPerSendingInterval = Int(maxPerSending)
    }
    
    /// The error delegate. Any core data error or network error will be forwarded to the delegate.
    public private(set) weak var errorDelegate: CDAgentErrorDelegate?
    /// The maximum number of spans per seconds to be saved in memory before the next saving operation on disk.
    public let maximumSpansPerSecond: Int
    /// The time between each saving operation on disk.
    public let savingInterval: TimeInterval
    /// The time between each sending tasks to the collector.
    public let sendingInterval: TimeInterval
    /** The maximum number of spans to be saved in memory before the next saving operation on disk.
     This is the product between the `maximumSpansPerSecond` and the `savingInterval`.
     */
    public let maximunSpansPerSavingInterval: Int
    /**  The maximum number of spans fetched from the disk before sending to the collector.
     This is the product between the `maximumSpansPerSecond` and the `sendingInterval`.
     */
    public let maximunSpansPerSendingInterval: Int
    /// An optional URL to a folder where the core data files will be saved. When not specified the `NSPersistentContainer.defaultDirectoryURL()` will be used.
    public let coreDataFolderURL: URL?
}
