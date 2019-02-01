//
//  AgentCoreDataObjectModel.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 2/1/19.
//

import CoreData

/// The Core Data model for the Agent written in Code.
enum AgentCoreDataObjectModel {

    /// The Core Data model for the Agent written in Code.
    static let model: NSManagedObjectModel = {

        let model = NSManagedObjectModel()

        // Core Data Span
        let coreDataSpan = NSEntityDescription()
        coreDataSpan.name = "CoreDataSpan"
        coreDataSpan.managedObjectClassName = "CoreDataSpan"

        // Property 1: Binary Data representing the span
        let jsonSpan = NSAttributeDescription()
        jsonSpan.name = "jsonSpan"
        jsonSpan.attributeType = .binaryDataAttributeType
        jsonSpan.isOptional = false
        jsonSpan.allowsExternalBinaryDataStorage = true

        // Property 2: the span start time, it is useful to order queries
        let startTime = NSAttributeDescription()
        startTime.name = "startTime"
        startTime.attributeType = .dateAttributeType
        jsonSpan.isOptional = false

        coreDataSpan.properties = [jsonSpan, startTime]
        model.entities = [coreDataSpan]

        return model
    }()
}
